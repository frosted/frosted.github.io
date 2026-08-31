---
title: The "Self-Documenting" Tenant - Exporting Intune to Markdown
date: 2026-08-25 09:00:00 +0500
categories: [Intune DevOps]
tags: [powershell, graph, intune, api, devops, documentation]     # TAG names should always be lowercase
---

### Introduction

Every Intune admin knows the documentation trap.

You spend an afternoon writing clean internal docs for your configuration profiles, assignment strategy, and baseline settings. It looks perfect on day one. Then someone updates a profile in the portal, tweaks a setting during an incident, or rolls out a quick exception for a pilot group.

Now your documentation is stale.

That is documentation debt: the gap between what your environment is and what your docs claim it is. Manual documentation will always lose this race. The only real cure is automation.

### The Goal: A Self-Documenting Tenant

A self-documenting tenant is simple in concept:

1. Use PowerShell + Microsoft Graph to pull Intune configuration data.
2. Convert the exported data into readable Markdown.
3. Store those Markdown files in Git.
4. Run this on a schedule so docs update automatically.

Result: your documentation reflects reality, not memory.

This is a practical `#powershell #graph #intune #api` pattern that builds directly on the same DevOps habits from recent posts: source control, repeatable scripts, and automation-first operations.

### Why Markdown and Git?

Markdown is easy for everyone to read and search, even outside admin tools. Git adds history, diffs, and accountability.

Together, they give you:

- Human-readable technical documentation
- Version-controlled change tracking
- Simple collaboration through pull requests
- A built-in audit timeline without manual note-taking

### Technical Implementation

The script below exports Intune configuration policies, extracts useful settings data, and writes one Markdown file per policy.

```powershell
Import-Module Microsoft.Graph.DeviceManagement

Connect-MgGraph -Scopes "DeviceManagementConfiguration.Read.All"
Select-MgProfile -Name "beta"

$outputRoot = "./docs/intune/configuration-policies"
if (-not (Test-Path $outputRoot)) {
    New-Item -Path $outputRoot -ItemType Directory -Force | Out-Null
}

$policies = Get-MgDeviceManagementConfigurationPolicy -All

foreach ($policy in $policies) {
    $policyId = $policy.Id
    $policyName = $policy.Name
    $safeName = ($policyName -replace '[\\/:*?"<>|]', '_')

    # Pull full policy details with settings
    $uri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/$policyId?`$expand=settings"
    $detail = Invoke-MgGraphRequest -Method GET -Uri $uri

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# $policyName") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("- **Policy ID**: $($detail.id)") | Out-Null
    $lines.Add("- **Description**: $($detail.description)") | Out-Null
    $lines.Add("- **Platforms**: $($detail.platforms)") | Out-Null
    $lines.Add("- **Technologies**: $($detail.technologies)") | Out-Null
    $lines.Add("- **Last Exported (UTC)**: $(Get-Date -AsUTC -Format 'yyyy-MM-dd HH:mm:ss')") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Settings") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("| Setting | Value |") | Out-Null
    $lines.Add("|---|---|") | Out-Null

    # Parse settings into a readable Markdown table
    foreach ($setting in $detail.settings) {
        $settingName = $setting.settingDefinitionId

        # Settings values can be nested; convert to compact JSON for readability
        $settingValue = ($setting | ConvertTo-Json -Depth 20 -Compress)

        # Escape markdown pipe characters to keep table structure intact
        $settingValue = $settingValue -replace '\|', '\|'

        $lines.Add("| $settingName | $settingValue |") | Out-Null
    }

    if (-not $detail.settings -or $detail.settings.Count -eq 0) {
        $lines.Add("| _No explicit settings returned_ | _n/a_ |") | Out-Null
    }

    $filePath = Join-Path $outputRoot "$safeName.md"
    $lines | Set-Content -Path $filePath -Encoding UTF8

    Write-Host "Exported markdown: $filePath"
}
```

### Parsing JSON into Useful Markdown

Graph responses are rich, but not always immediately readable.

A practical transformation approach:

1. Keep policy metadata at the top (name, ID, platforms, timestamp).
2. Flatten individual settings into rows.
3. Store complex nested values as compact JSON for accuracy.
4. Write one policy per Markdown file to keep docs modular.

This gives your team docs that are both human-friendly and technically precise.

### DevOps Automation: Nightly Azure DevOps Pipeline

To make this truly self-documenting, run the export automatically on a schedule.

A nightly pipeline can:

1. Run the export script.
2. Detect file changes.
3. Commit updated Markdown to the repo.
4. Push changes, creating an automatic audit trail.

Sample Azure DevOps pipeline:

```yaml
trigger: none

schedules:
- cron: "0 2 * * *"
  displayName: Nightly Intune Markdown Export
  branches:
    include:
    - main
  always: true

pool:
  vmImage: ubuntu-latest

steps:
- checkout: self
  persistCredentials: true

- task: PowerShell@2
  displayName: Export Intune policies to Markdown
  inputs:
    targetType: inline
    pwsh: true
    script: |
      Install-Module Microsoft.Graph -Scope CurrentUser -Force

      $tenantId = "$(TENANT_ID)"
      $clientId = "$(CLIENT_ID)"
      $clientSecret = "$(CLIENT_SECRET)"

      $secureSecret = ConvertTo-SecureString $clientSecret -AsPlainText -Force
      $credential = New-Object System.Management.Automation.PSCredential($clientId, $secureSecret)

      Connect-MgGraph -TenantId $tenantId -ClientSecretCredential $credential

      ./scripts/export-intune-markdown.ps1

- task: PowerShell@2
  displayName: Commit and push documentation changes
  inputs:
    targetType: inline
    pwsh: true
    script: |
      git config user.email "pipeline@frosted.local"
      git config user.name "Frosted Automation"

      git add docs/intune/configuration-policies

      if (git diff --cached --quiet) {
        Write-Host "No documentation changes detected."
      }
      else {
        git commit -m "Nightly Intune documentation export"
        git push origin HEAD:main
      }
```

What this means operationally: if someone changes a setting in the Intune portal, the next pipeline run captures that drift in Markdown and commits it to source control automatically.

### Value Proposition: Making Audits and Handover Easy

This approach removes fragile tribal knowledge from your operations model.

For compliance teams, you get historical, timestamped evidence of how configuration evolved.
For new team members, you get searchable, current documentation without waiting for a handover call.
For incident response, you can quickly compare yesterday vs today and identify what changed.

That is exactly what making ops easy looks like in practice: less guesswork, faster answers, and repeatable transparency.

### Operational Best Practices

1. Keep generated docs in a dedicated folder (for example, `docs/intune/configuration-policies`).
2. Use a service principal with least-privilege Graph permissions.
3. Protect `main` with branch policies, even for automation commits if your workflow requires PRs.
4. Add a summary index file that links all exported policy Markdown documents.
5. Pair this pipeline with your existing version-control and IaC flows for a full lifecycle model.

### Conclusion

A self-documenting tenant is not about writing better docs manually. It is about eliminating manual documentation as an operational dependency.

By exporting Intune through Graph, transforming it into Markdown, and committing those results automatically, you build living documentation that stays aligned with reality.

For modern IT Ops teams, this is a high-leverage move: better audits, easier collaboration, and fewer surprises.

### References

- [Microsoft Graph PowerShell SDK Overview](https://learn.microsoft.com/powershell/microsoftgraph/overview)
- [Get-MgDeviceManagementConfigurationPolicy](https://learn.microsoft.com/powershell/module/microsoft.graph.devicemanagement/get-mgdevicemanagementconfigurationpolicy)
- [Invoke-MgGraphRequest](https://learn.microsoft.com/powershell/module/microsoft.graph.authentication/invoke-mggraphrequest)
- [Azure DevOps Pipelines Documentation](https://learn.microsoft.com/azure/devops/pipelines/?view=azure-devops)
