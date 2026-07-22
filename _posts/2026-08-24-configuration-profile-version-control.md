---
title: Configuration Profile Version Control
date: 2026-07-22 09:01:00 +0500
categories: [Foundational Series]
tags: [powershell, graph, intune, api]     # TAG names should always be lowercase
---

### Introduction

You make what looks like a tiny configuration change in Intune at 4:45 PM. Maybe it is a compliance setting tweak, maybe a settings catalog update for BitLocker, maybe a policy assignment adjustment.

By 5:10 PM, helpdesk tickets start rolling in. Devices are reporting unexpected behavior, users cannot complete a task they could do an hour earlier, and everyone asks the same question: "What changed?"

This is exactly where modern operations needs an undo button.

For most Intune admins, configuration changes are still too manual and too portal-driven. That makes troubleshooting harder and rollbacks slower than they should be. In this post, we will fix that by version controlling your Intune Configuration Profiles as JSON so you can:

- Track exactly what changed
- Compare versions with Git diffs
- Restore a known good configuration when something breaks

### Prerequisites

Before you start, make sure you have:

- The Microsoft Graph PowerShell SDK installed (`Microsoft.Graph`)
- Permission to read and manage Intune configuration profiles
- An authenticated Graph session connected to your tenant

If you need a quick refresher on module setup and authentication, check the earlier Foundational Series post on connecting to Intune.

### Why Version Control Intune Profiles?

Intune is incredibly powerful, but portal changes are easy to make and hard to audit in detail over time.

When you export profiles to JSON and commit them into Git, you get operational benefits immediately:

- **Change history**: Every modification has a timestamp and commit trail
- **Review workflow**: You can inspect diffs before and after policy edits
- **Rollback safety**: Known good versions are always available
- **Team visibility**: Everyone can see what changed without clicking through the portal

Think of this as Infrastructure as Code principles applied to endpoint management.

### Step 1: Connect to Graph and Pull Configuration Profiles

The script below uses `Get-MgDeviceManagementConfigurationPolicy` to export configuration policies from Intune.

This is a practical `#powershell #graph #intune #api` workflow that turns portal configuration into trackable artifacts.

```powershell
# Requires Microsoft.Graph.DeviceManagement module (included with Microsoft.Graph)
Import-Module Microsoft.Graph.DeviceManagement

# Connect with scopes required for policy export/import
Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All"

# Optional: target beta profile for configurationPolicies endpoint parity
Select-MgProfile -Name "beta"

# Export location
$exportRoot = "./intune-config-backups"
if (-not (Test-Path $exportRoot)) {
    New-Item -Path $exportRoot -ItemType Directory | Out-Null
}

# Pull all Intune configuration policies
$profiles = Get-MgDeviceManagementConfigurationPolicy -All

foreach ($profile in $profiles) {
    # Build a safe file name
    $safeName = ($profile.Name -replace '[\\/:*?"<>|]', '_')
    $fileName = "{0}_{1}.json" -f $safeName, $profile.Id
    $filePath = Join-Path $exportRoot $fileName

    # Pull full policy details before export
    $policyDetail = Get-MgDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $profile.Id

    # Save JSON with enough depth for nested settings
    $policyDetail | ConvertTo-Json -Depth 25 | Out-File -FilePath $filePath -Encoding utf8
    Write-Host "Exported: $fileName"
}
```

### Step 2: Store Exports in GitHub for Diffs and Audit Trail

Once profiles are exported, commit them to a GitHub repository just like code.

Example workflow:

1. Export profiles to your local folder.
2. Commit the JSON files to a repository (private is recommended for production environments).
3. Re-export after policy changes.
4. Use Git diffs to see exactly what changed.

```powershell
# From inside your backup repository

git add .
git commit -m "Intune policy export - baseline"
git push

# Later, after policy updates
# Re-run export script, then:
git add .
git commit -m "Intune policy export - post hardening updates"
git push
```

Now your policy history is searchable, reviewable, and recoverable.

### Step 3: Disaster Recovery - Re-Upload a Known Good Configuration

When a policy change causes issues, you can restore by importing a previously exported JSON file.

The restore pattern below:

- Reads a known good backup file
- Removes read-only properties that cannot be posted back
- Re-creates the policy via Graph API

```powershell
Import-Module Microsoft.Graph.DeviceManagement
Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All"
Select-MgProfile -Name "beta"

$backupFile = "./intune-config-backups/Windows_BitLocker_Baseline_aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee.json"
$raw = Get-Content -Path $backupFile -Raw
$policy = $raw | ConvertFrom-Json

# Remove read-only/system-managed properties before restore
$null = $policy.PSObject.Properties.Remove('id')
$null = $policy.PSObject.Properties.Remove('createdDateTime')
$null = $policy.PSObject.Properties.Remove('lastModifiedDateTime')
$null = $policy.PSObject.Properties.Remove('version')
$null = $policy.PSObject.Properties.Remove('@odata.context')
$null = $policy.PSObject.Properties.Remove('settingCount')
$null = $policy.PSObject.Properties.Remove('isAssigned')

$body = $policy | ConvertTo-Json -Depth 25

Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -Body $body -ContentType "application/json"

Write-Host "Restore submitted. Validate the new policy and assignments in Intune."
```

> **Important**: Recreated policies get a new object ID. You may need to re-assign the restored profile to the correct groups.
{: .prompt-tip }

### Operational Tips

1. **Use scheduled exports**: Run the export script daily or after every approved change window.
2. **Separate repos by environment**: Keep production and test backups isolated.
3. **Review before import**: Always inspect JSON before restore, especially assignment-related values.
4. **Pair with change tickets**: Include the Git commit hash in your incident or change record.

### References

- [Getting Started with PowerShell for Intune - Connecting to Intune]({% post_url 2024-10-27-connecting-intune %})
- [Managing Intune Resources with PowerShell - Essential Commands and Tasks]({% post_url 2024-11-10-essential-commands-and-tasks %})
- [Microsoft Graph PowerShell SDK Overview](https://learn.microsoft.com/powershell/microsoftgraph/overview)
- [Connect-MgGraph](https://learn.microsoft.com/powershell/module/microsoft.graph.authentication/connect-mggraph)
- [Get-MgDeviceManagementConfigurationPolicy](https://learn.microsoft.com/powershell/module/microsoft.graph.devicemanagement/get-mgdevicemanagementconfigurationpolicy)
- [Invoke-MgGraphRequest](https://learn.microsoft.com/powershell/module/microsoft.graph.authentication/invoke-mggraphrequest)
- [git diff Documentation](https://git-scm.com/docs/git-diff)

### Conclusion

Configuration profile version control gives Intune admins something the portal alone does not: confidence.

With PowerShell, Graph API, and GitHub, you can move from reactive troubleshooting to controlled, auditable operations. When a configuration drifts or a change backfires, you have a clear path to compare, diagnose, and restore quickly.

That is the real value of an undo button in modern endpoint management.

In the next post, we can build on this by automating profile export and commit with Task Scheduler so your backups happen continuously in the background.
