---
title: Automate Device Cleanup in Microsoft Intune with PowerShell
date: 2024-11-03 20:13:00 +0500
categories: [Foundational Series]
tags: [intune, powershell, graph]     # TAG names should always be lowercase
---

### Introduction

Managing devices in Microsoft Intune is crucial to keeping your organization’s environment secure and efficient. Over time, however, inactive or obsolete devices can clutter up the Microsoft Intune admin center, making it harder to manage effectively. Manual cleanup is time-consuming, but with PowerShell, you can automate this process, save time, and keep your environment organized.

In this post, I’ll show you a PowerShell script that uses the Microsoft Graph PowerShell SDK (the Microsoft-recommended approach for Intune automation) to identify and remove inactive devices in Intune. By the end, you’ll have a reliable way to maintain a clean device inventory, which is especially helpful in large organizations.

### Prerequisites

To follow along, ensure you have:

- **Microsoft Graph PowerShell SDK (v2+)**: Install with `Install-Module Microsoft.Graph -Scope CurrentUser`.
- **Required delegated permissions**: `DeviceManagementManagedDevices.Read.All` (read) and `DeviceManagementManagedDevices.ReadWrite.All` (delete).
- **Administrator role**: Intune Administrator (or an equivalent role) in Microsoft Entra ID.

Use least-privilege access whenever possible: if you only need reporting, connect with read-only scope; only use read/write scope when you’re actually performing deletions.

### Script: Cleaning Up Inactive Devices

Here’s a beginner-friendly script to identify devices inactive for 90 days or more and remove them from Intune. It includes:

- Microsoft Graph PowerShell SDK cmdlets
- Retrieval of all managed devices
- Validation for devices that have no `LastSyncDateTime`
- A `-WhatIf` safety mechanism before deletion
- Error handling with `try/catch`

```powershell
# Connect to Microsoft Graph with delegated permissions
# Use read-only scope for reporting runs when you do not plan to delete.
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All","DeviceManagementManagedDevices.ReadWrite.All"

# Optional: confirm the current Graph context
Get-MgContext

# Define the inactivity threshold (in days)
$inactivityThreshold = 90
$cutoffDate = (Get-Date).AddDays(-$inactivityThreshold)

# Safety switch: keep as $true to preview deletions first
$whatIfMode = $true

try {
    # Retrieve all managed devices from Intune
    $devices = Get-MgDeviceManagementManagedDevice -All
}
catch {
    Write-Error "Failed to retrieve managed devices. $_"
    return
}

# Split devices into those with and without LastSyncDateTime
$devicesWithNoSync = @($devices | Where-Object { -not $_.LastSyncDateTime })
$inactiveDevices = @($devices | Where-Object {
    $_.LastSyncDateTime -and ([datetime]$_.LastSyncDateTime -lt $cutoffDate)
})

if ($devicesWithNoSync.Count -gt 0) {
    Write-Host "Devices with no LastSyncDateTime (review manually):" -ForegroundColor Cyan
    $devicesWithNoSync | ForEach-Object {
        Write-Host " - $($_.DeviceName)"
    }
    Write-Host ""
}

# Display inactive devices before deletion
Write-Host "Devices inactive for over $inactivityThreshold days:" -ForegroundColor Yellow
$inactiveDevices | ForEach-Object {
    Write-Host "$($_.DeviceName) - Last Sync: $($_.LastSyncDateTime)"
}

# Confirm deletion of inactive devices
if ($inactiveDevices.Count -gt 0) {
    $confirmation = Read-Host "Do you want to delete these devices? (Y/N)"
    
    if ($confirmation -eq 'Y') {
        # Delete each inactive device
        $inactiveDevices | ForEach-Object {
            try {
                Remove-MgDeviceManagementManagedDevice -ManagedDeviceId $_.Id -WhatIf:$whatIfMode -ErrorAction Stop
                if ($whatIfMode) {
                    Write-Host "WhatIf: Would delete $($_.DeviceName)" -ForegroundColor Yellow
                }
                else {
                    Write-Host "Deleted $($_.DeviceName)" -ForegroundColor Green
                }
            }
            catch {
                Write-Warning "Failed to delete $($_.DeviceName). $_"
            }
        }
    } else {
        Write-Host "Operation canceled." -ForegroundColor Red
    }
} else {
    Write-Host "No inactive devices found." -ForegroundColor Green
}
```

### Explanation

1. **Connect to Microsoft Graph**: We authenticate using `Connect-MgGraph` with delegated scopes for managed device read and delete actions.
   
2. **Define Inactivity Threshold**: In this case, we set a threshold of 90 days, but this can be customized based on your organization’s needs.

3. **Retrieve Device Data**: Using `Get-MgDeviceManagementManagedDevice -All`, we collect all devices managed by Intune.

4. **Filter Inactive Devices**: We compare `LastSyncDateTime` (the last successful Intune synchronization) to the cutoff date. We also separate devices with null sync values so they can be reviewed safely.

5. **Delete Inactive Devices Safely**: After confirmation, deletion runs with `try/catch` for reliability and supports `WhatIf` mode for a safe preview before actual removal.

### Outcome

This script helps you maintain a lean and efficient Intune environment by removing outdated devices that could otherwise clutter up the Microsoft Intune admin center. Be cautious, though, as deleted devices can’t be recovered.

Always test in a non-production tenant before running bulk deletions.

### Next Steps

In future posts, I’ll dive deeper into Intune management with PowerShell, covering tasks like device enrollment management, reporting, and policy automation. If you have specific topics or questions, feel free to leave a comment or reach out!

### Conclusion

Automating Intune tasks with PowerShell isn’t just a time-saver, it’s a way to streamline operations and stay on top of device management in a dynamic IT environment. Using the Microsoft Graph PowerShell SDK keeps your automation aligned with Microsoft’s current guidance for Intune and Microsoft Entra ID.

Thanks for reading, and happy scripting!

