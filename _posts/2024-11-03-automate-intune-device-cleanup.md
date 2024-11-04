---
title: Automate Device Cleanup in Microsoft Intune with PowerShell
date: 2024-11-03 20:13:00 +0500
categories: [Foundational Series]
tags: [intune, powershell, graph]     # TAG names should always be lowercase
---

### Introduction

Managing devices in Microsoft Intune is crucial to keeping your organization’s environment secure and efficient. Over time, however, inactive or obsolete devices can clutter up your Intune portal, making it challenging to manage effectively. Manual cleanup is time-consuming, but with PowerShell, you can automate this process, saving time and keeping your environment organized.

In this post, I’ll show you a PowerShell script to identify and remove inactive devices in Intune. By the end, you’ll have a reliable way to maintain a clean device inventory, which is especially helpful in large organizations.

### Prerequisites

To follow along, ensure you have:

- **AzureAD Module**: Installed and updated to the latest version.
- **Intune PowerShell Module**: [Microsoft.Graph.Intune](https://www.powershellgallery.com/packages/Microsoft.Graph.Intune).
- **Administrator Permissions**: Permissions to read and delete devices in Intune.

### Script: Cleaning Up Inactive Devices

Here’s a PowerShell script to identify devices inactive for 90 days or more and remove them from Intune.

```powershell
# Import the required module
Import-Module Microsoft.Graph.Intune

# Sign into your Intune environment
Connect-MSGraph

# Define the inactivity threshold (in days)
$inactivityThreshold = 90

# Get all devices in Intune
$devices = Get-IntuneManagedDevice

# Filter for inactive devices
$inactiveDevices = $devices | Where-Object {
    ($_ | Select-Object -ExpandProperty LastContact) -lt (Get-Date).AddDays(-$inactivityThreshold)
}

# Display inactive devices before deletion
Write-Host "Devices inactive for over $inactivityThreshold days:" -ForegroundColor Yellow
$inactiveDevices | ForEach-Object {
    Write-Host "$($_.DeviceName) - Last Contact: $($_.LastContact)"
}

# Confirm deletion of inactive devices
if ($inactiveDevices.Count -gt 0) {
    $confirmation = Read-Host "Do you want to delete these devices? (Y/N)"
    
    if ($confirmation -eq 'Y') {
        # Delete each inactive device
        $inactiveDevices | ForEach-Object {
            Remove-IntuneManagedDevice -Id $_.Id
            Write-Host "Deleted $($_.DeviceName)" -ForegroundColor Green
        }
    } else {
        Write-Host "Operation canceled." -ForegroundColor Red
    }
} else {
    Write-Host "No inactive devices found." -ForegroundColor Green
}
```

### Explanation

1. **Connect to Intune**: After importing the necessary module, we authenticate to Intune using `Connect-MSGraph`.
   
2. **Define Inactivity Threshold**: In this case, we set a threshold of 90 days, but this can be customized based on your organization’s needs.

3. **Retrieve Device Data**: Using `Get-IntuneManagedDevice`, we collect all devices managed by Intune. 

4. **Filter Inactive Devices**: By comparing the `LastContact` date, we identify devices that haven’t been in contact within the set threshold.

5. **Delete Inactive Devices**: After confirmation, the script deletes each inactive device from Intune. This step is optional and can be modified to mark devices instead of deleting them directly.

### Outcome

This script will help you maintain a lean and efficient Intune environment by removing outdated devices that could otherwise clutter up your portal. Be cautious, though, as deleted devices can’t be recovered. Test the script in a non-production environment before deploying it across your organization.

### Next Steps

In future posts, I’ll dive deeper into Intune management with PowerShell, covering tasks like device enrollment management, reporting, and policy automation. If you have specific topics or questions, feel free to leave a comment or reach out!

### Conclusion

Automating Intune tasks with PowerShell isn’t just a time-saver—it’s a way to streamline operations and stay on top of device management in a dynamic IT environment. I’ll be sharing more scripts and best practices in future posts, so stay tuned!

Thanks for reading, and happy scripting!

