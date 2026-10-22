---
title: Configuration Profile Version Control
date: 2026-07-28 22:02:00 +0500
categories: [Intune Devops]
tags: [powershell, graph, intune, devops]     # TAG names should always be lowercase
---

### Introduction

You make what looks like a tiny configuration change in Intune at 4:45 PM. Maybe it is a compliance setting tweak, maybe a settings catalog update for BitLocker, maybe a policy assignment adjustment.

By 5:10 PM, helpdesk tickets start rolling in. Devices are reporting unexpected behavior, users cannot complete a task they could do an hour earlier, and everyone asks the same question: "What changed?"

This is exactly where modern operations need an undo button.

For most Intune admins, configuration changes are still too manual and too portal-driven. That makes troubleshooting harder and rollbacks slower than they should be. In this post, we will fix that by version controlling your Intune Configuration Profiles as JSON so you can:

- Track exactly what changed
- Compare versions with Git diffs
- Restore or recreate a known good configuration when something breaks

This article uses the Microsoft Graph beta PowerShell modules because configuration policy cmdlets are currently exposed there in Microsoft Graph PowerShell SDK v2+.

### Prerequisites

Before you start, make sure you have:

- The Microsoft Graph PowerShell SDK installed (`Microsoft.Graph`)
- The beta Device Management module installed (`Microsoft.Graph.Beta.DeviceManagement`)
- Read permission for export scenarios: `DeviceManagementConfiguration.Read.All`
- Read/write permission for restore scenarios: `DeviceManagementConfiguration.ReadWrite.All`
- An authenticated Graph session connected to your tenant

Use least privilege whenever possible. Read-only export jobs should not request write scope, and restore jobs should request write scope only when you are ready to recreate a policy.

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

The script below uses the beta configuration policy cmdlets to export configuration policies from Intune.

This is a practical `#powershell #graph #intune #api` workflow that turns portal configuration into trackable artifacts.

```powershell
# Requires the beta device management module
Import-Module Microsoft.Graph.Beta.DeviceManagement

# Connect with read-only scope for export
Connect-MgGraph -Scopes "DeviceManagementConfiguration.Read.All"

# Optional: verify the current Graph context
Get-MgContext

# Export location
$exportRoot = "./intune-config-backups"
if (-not (Test-Path $exportRoot)) {
    New-Item -Path $exportRoot -ItemType Directory | Out-Null
}

# Pull all Intune configuration policies
$profiles = Get-MgBetaDeviceManagementConfigurationPolicy -All

foreach ($profile in $profiles) {
    # Build a safe file name
    $safeName = ($profile.Name -replace '[\\/:*?"<>|]', '_')
    $fileName = "{0}_{1}.json" -f $safeName, $profile.Id
    $filePath = Join-Path $exportRoot $fileName

    # Pull full policy details before export, including assignments when available
    $policyDetail = Get-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $profile.Id -ExpandProperty assignments

    # Save JSON with enough depth for nested settings
    $policyDetail | ConvertTo-Json -Depth 50 | Out-File -FilePath $filePath -Encoding utf8
    Write-Host "Exported: $fileName"
}

# Clean up the Graph session
Disconnect-MgGraph -ErrorAction SilentlyContinue
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
- Re-creates the policy via Microsoft Graph beta PowerShell cmdlets
- Restores the policy definition, not every related dependency automatically

```powershell
Import-Module Microsoft.Graph.Beta.DeviceManagement
Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All"

$backupFile = "./intune-config-backups/Windows_BitLocker_Baseline_aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee.json"
$raw = Get-Content -Path $backupFile -Raw
$policy = $raw | ConvertFrom-Json

# Remove read-only/system-managed properties before restore
$null = $policy.PSObject.Properties.Remove('id')
$null = $policy.PSObject.Properties.Remove('createdDateTime')
$null = $policy.PSObject.Properties.Remove('lastModifiedDateTime')
$null = $policy.PSObject.Properties.Remove('@odata.context')
$null = $policy.PSObject.Properties.Remove('settingCount')
$null = $policy.PSObject.Properties.Remove('isAssigned')
$null = $policy.PSObject.Properties.Remove('assignments')

$body = $policy | ConvertTo-Json -Depth 50 | ConvertFrom-Json

New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $body

Write-Host "Restore submitted. Validate the new policy, assignments, and scope tags in Intune."

# Clean up the Graph session
Disconnect-MgGraph -ErrorAction SilentlyContinue
```

> **Important**: Recreated policies get a new object ID. You may need to re-assign the restored profile to the correct groups and verify scope tags after restore.
{: .prompt-tip }

### Known Limitations

Keep these limitations in mind before you rely on exports for disaster recovery:

- Assignments may not be restored exactly as they were in the portal and may need to be re-applied manually.
- Scope tags should be reviewed after restore, especially when moving content between tenants or environments.
- Restored policies receive new object IDs, so downstream references and automation need to be updated.
- Settings Catalog policies may require additional validation because exported JSON can be incomplete or change shape as Microsoft updates the beta API.
- Test your export and restore process in a non-production tenant before relying on it for real recovery.
- Some policy types may contain additional child resources or settings that are not fully represented in a single policy export and should be validated after restoration.

### Operational Tips

1. **Use scheduled exports**: Run the export script daily or after every approved change window.
2. **Separate repos by environment**: Keep production and test backups isolated.
3. **Review before import**: Always inspect JSON before restore, especially assignment-related values.
4. **Pair with change tickets**: Include the Git commit hash in your incident or change record.

### References

- [Getting Started with PowerShell for Intune - Connecting to Intune]({% post_url 2024-10-27-connecting-intune %})
- [Managing Intune Resources with PowerShell - Essential Commands and Tasks]({% post_url 2024-11-10-essential-commands-and-tasks %})
- [Microsoft Graph PowerShell SDK Overview](https://learn.microsoft.com/powershell/microsoftgraph/overview)
- [Upgrade from Azure AD PowerShell to Microsoft Graph PowerShell](https://learn.microsoft.com/en-us/powershell/microsoftgraph/migration-steps)
- [Connect-MgGraph](https://learn.microsoft.com/powershell/module/microsoft.graph.authentication/connect-mggraph)
- [Get-MgBetaDeviceManagementConfigurationPolicy](https://learn.microsoft.com/powershell/module/microsoft.graph.beta.devicemanagement/get-mgbetadevicemanagementconfigurationpolicy)
- [New-MgBetaDeviceManagementConfigurationPolicy](https://learn.microsoft.com/powershell/module/microsoft.graph.beta.devicemanagement/new-mgbetadevicemanagementconfigurationpolicy)
- [git diff Documentation](https://git-scm.com/docs/git-diff)

### Conclusion

Configuration profile version control gives Intune admins something the portal alone does not: confidence.

With PowerShell, Graph API, and GitHub, you can move from reactive troubleshooting to controlled, auditable operations. When a configuration drifts or a change backfires, you have a clear path to compare, diagnose, and restore quickly.

That is the real value of an undo button in modern endpoint management.

In the next post, we can build on this by automating profile export and commit with Task Scheduler so your backups happen continuously in the background.
