---
title: Infrastructure as Code (IaC) for Intune - Moving Beyond Manual Management
date: 2026-08-23 09:00:00 +0500
categories: [Intune Devops]
tags: [powershell, graph, intune, api, devops]     # TAG names should always be lowercase
---

### Introduction

If you have managed Intune long enough, you have probably lived this moment: a small manual change in the portal looks harmless, but hours later devices drift, settings conflict, and troubleshooting turns into guesswork.

That is where Infrastructure as Code (IaC) changes the game.

In the Intune world, IaC means defining your configurations as code and deploying them through repeatable automation instead of manual portal-clicking. It is not just a “developer” concept. For IT operations, this is how we make ops easy: fewer human errors, cleaner changes, faster rollbacks, and better scale.

This post builds directly on [Configuration Profile Version Control]({% post_url 2026-07-28-configuration-profile-version-control %}) and the Foundational Series principles of connecting through Microsoft Graph and maintaining a clean, controlled environment.

### Prerequisites

Before starting, make sure you have:

- `Microsoft.Graph` installed and updated
- Permissions for Intune configuration policy read/write operations
- An authenticated Graph session (`Connect-MgGraph`)

If you need a refresher, review the connection workflow from [Getting Started with PowerShell for Intune - Connecting to Intune]({% post_url 2024-10-27-connecting-intune %}), and for environment hygiene, revisit [Automate Device Cleanup in Microsoft Intune with PowerShell]({% post_url 2024-11-03-automate-intune-device-cleanup %}).

### Imperative vs Declarative Management

Before we write code, it helps to understand the two operating models.

1. **Imperative**: You script each step (create this profile, set this value, assign to that group).
2. **Declarative**: You define the desired end state in code (this profile should exist with these settings), and automation enforces it.

Imperative scripts are useful, especially for one-off operations. Declarative workflows are what unlock consistency and scale because they focus on state, not clicks.

In practice, most Intune teams start imperative and gradually move declarative as their profile library grows.

### Technical Implementation: Deploy a JSON Configuration Profile

The workflow below uses `#powershell #graph #intune #api` to read a JSON file from your repository and create a configuration policy in Intune.

```powershell
Import-Module Microsoft.Graph.DeviceManagement
Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All"
Select-MgProfile -Name "beta"

# Path to your version-controlled policy JSON file
$profilePath = "./intune-policies/Windows-BitLocker-Policy.json"

if (-not (Test-Path $profilePath)) {
    throw "Profile file not found: $profilePath"
}

$profile = Get-Content -Path $profilePath -Raw | ConvertFrom-Json

# Remove read-only fields that cannot be submitted when creating a new policy
$null = $profile.PSObject.Properties.Remove('id')
$null = $profile.PSObject.Properties.Remove('createdDateTime')
$null = $profile.PSObject.Properties.Remove('lastModifiedDateTime')
$null = $profile.PSObject.Properties.Remove('version')
$null = $profile.PSObject.Properties.Remove('settingCount')
$null = $profile.PSObject.Properties.Remove('isAssigned')
$null = $profile.PSObject.Properties.Remove('@odata.context')

$body = $profile | ConvertTo-Json -Depth 30

Invoke-MgGraphRequest \
    -Method POST \
    -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" \
    -Body $body \
    -ContentType "application/json"

Write-Host "Configuration profile deployment submitted."
```

### Idempotency: Avoid Duplicates and Keep the Environment Clean

If you run a deployment script repeatedly, it should not create duplicate profiles. This is where idempotency matters.

A simple pattern:

- Read the desired profile name from JSON
- Check Intune for an existing profile with that exact name
- Create only if it does not already exist

```powershell
Import-Module Microsoft.Graph.DeviceManagement
Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All"
Select-MgProfile -Name "beta"

$profilePath = "./intune-policies/Windows-BitLocker-Policy.json"
$profile = Get-Content -Path $profilePath -Raw | ConvertFrom-Json

$desiredName = $profile.name
if ([string]::IsNullOrWhiteSpace($desiredName)) {
    throw "The JSON file does not contain a valid profile name."
}

$existing = Get-MgDeviceManagementConfigurationPolicy -All | Where-Object {
    $_.Name -eq $desiredName
}

if ($existing) {
    Write-Host "Profile '$desiredName' already exists. Skipping create to preserve idempotency."
}
else {
    $null = $profile.PSObject.Properties.Remove('id')
    $null = $profile.PSObject.Properties.Remove('createdDateTime')
    $null = $profile.PSObject.Properties.Remove('lastModifiedDateTime')
    $null = $profile.PSObject.Properties.Remove('version')
    $null = $profile.PSObject.Properties.Remove('settingCount')
    $null = $profile.PSObject.Properties.Remove('isAssigned')
    $null = $profile.PSObject.Properties.Remove('@odata.context')

    $body = $profile | ConvertTo-Json -Depth 30

    Invoke-MgGraphRequest \
        -Method POST \
        -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" \
        -Body $body \
        -ContentType "application/json"

    Write-Host "Profile '$desiredName' created successfully."
}
```

This pattern supports the same clean-environment mindset from your foundational content: deterministic changes, minimal drift, and no accidental clutter.

### Scaling with CI/CD: GitHub Actions for Intune Deployments

Once your policy JSON lives in Git, deployment can be automated.

At a high level:

1. Commit policy changes to the repository.
2. GitHub Actions triggers on push.
3. Workflow authenticates to Microsoft Graph with a service principal.
4. Deployment script runs and applies idempotent logic.

Minimal workflow example:

```yaml
name: Deploy Intune Policies

on:
  push:
    paths:
      - 'intune-policies/**.json'
      - 'scripts/deploy-intune-policy.ps1'

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Install Microsoft Graph PowerShell
        shell: pwsh
        run: |
          Install-Module Microsoft.Graph -Scope CurrentUser -Force

      - name: Deploy policy
        shell: pwsh
        env:
          AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          AZURE_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
        run: |
          $secureSecret = ConvertTo-SecureString $env:AZURE_CLIENT_SECRET -AsPlainText -Force
          $credential = New-Object System.Management.Automation.PSCredential($env:AZURE_CLIENT_ID, $secureSecret)
          Connect-MgGraph -TenantId $env:AZURE_TENANT_ID -ClientSecretCredential $credential
          ./scripts/deploy-intune-policy.ps1
```

### Operational Notes

1. **Use a dedicated app registration** with least-privilege Graph scopes.
2. **Start in test tenants** before production rollouts.
3. **Version every profile change** and tag releases for rollback points.
4. **Log every deployment result** to keep change audits clear.

### References

- [Getting Started with PowerShell for Intune - Connecting to Intune]({% post_url 2024-10-27-connecting-intune %})
- [Automate Device Cleanup in Microsoft Intune with PowerShell]({% post_url 2024-11-03-automate-intune-device-cleanup %})
- [Managing Intune Resources with PowerShell - Essential Commands and Tasks]({% post_url 2024-11-10-essential-commands-and-tasks %})
- [Configuration Profile Version Control]({% post_url 2026-07-28-configuration-profile-version-control %})
- [Microsoft Graph PowerShell SDK Overview](https://learn.microsoft.com/powershell/microsoftgraph/overview)
- [Connect-MgGraph](https://learn.microsoft.com/powershell/module/microsoft.graph.authentication/connect-mggraph)
- [Get-MgDeviceManagementConfigurationPolicy](https://learn.microsoft.com/powershell/module/microsoft.graph.devicemanagement/get-mgdevicemanagementconfigurationpolicy)
- [Invoke-MgGraphRequest](https://learn.microsoft.com/powershell/module/microsoft.graph.authentication/invoke-mggraphrequest)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [git diff Documentation](https://git-scm.com/docs/git-diff)

### Conclusion

Moving Intune configuration into code is no longer optional for modern operations. It is the path from reactive, manual administration to controlled, scalable delivery.

When your profiles are versioned, deployed through idempotent scripts, and automated in CI/CD, you reduce drift, lower risk, and speed up recovery.

That is what “making ops easy” looks like at scale.
