---
Title: Managing Intune Resources with PowerShell - Essential Commands and Tasks
date: 2024-11-10 16:03:00 +0500
categories: [Foundational Series]
tags: [intune, powershell, graph]     # TAG names should always be lowercase
---

### Introduction

Now that we’ve covered the basics of connecting to Microsoft Intune with PowerShell, it’s time to dive into managing Intune resources. In this post, I’ll introduce essential PowerShell commands for managing devices, configurations, and policies. By the end, you’ll have a toolkit of commands to simplify your day-to-day Intune administration tasks.

### Why Manage Intune with PowerShell?

While the Intune admin portal offers a robust UI, PowerShell allows you to automate repetitive tasks and handle complex scenarios efficiently. Whether you’re managing hundreds or thousands of devices, automating with PowerShell helps you keep the environment consistent, secure, and up-to-date.

### Step 1: Understanding Key Intune Resources

Microsoft Intune groups resources into several categories, with the most commonly managed ones being:

- **Devices**: All Intune-managed devices, such as desktops, laptops, and mobile devices.
- **Users**: Individual accounts and associated policies or applications.
- **Device Configurations**: Policies that manage device settings, such as security, compliance, and restrictions.
- **Applications**: Software deployed and managed through Intune, including required and available apps.
  
Each category has its own set of PowerShell commands, accessible via the Microsoft Graph SDK.

### Step 2: Managing Devices

Let’s start with some core commands to manage devices in Intune. Here’s how to list, retrieve, and perform basic actions on devices.

1. **Retrieve All Devices**:

   To get a list of all managed devices:

   ```powershell
   $devices = Get-MgDeviceManagementManagedDevice
   $devices | ForEach-Object { Write-Host $_.DeviceName }
   ```

   This command retrieves all devices and displays each device’s name. You can adjust this output to show other properties like `DeviceType`, `OperatingSystem`, or `ComplianceState`.

2. **Retrieve a Specific Device**:

   To get details about a single device, specify its unique identifier (Device ID):

   ```powershell
   $deviceId = "<YourDeviceID>"
   $device = Get-MgDeviceManagementManagedDevice -ManagedDeviceId $deviceId
   Write-Host "Device Name: $($device.DeviceName)"
   Write-Host "Compliance State: $($device.ComplianceState)"
   ```

3. **Remote Actions on Devices**:

   Using PowerShell, you can initiate remote actions on devices, like wiping or restarting them.

   - **Restart a Device**:

     ```powershell
     Invoke-MgDeviceManagementManagedDeviceRestart -ManagedDeviceId $deviceId
     Write-Host "Restart command sent to device $($device.DeviceName)"
     ```

   - **Wipe a Device**:

     ```powershell
     Invoke-MgDeviceManagementManagedDeviceWipe -ManagedDeviceId $deviceId
     Write-Host "Wipe command sent to device $($device.DeviceName)"
     ```

   These commands help enforce security and troubleshooting remotely across your device fleet.

### Step 3: Managing Device Configurations

Device configurations in Intune allow you to enforce settings on managed devices. Here’s how to view and manage them.

1. **List All Device Configurations**:

   To see all configurations applied within Intune:

   ```powershell
   $configs = Get-MgDeviceManagementDeviceConfiguration
   $configs | ForEach-Object { Write-Host $_.DisplayName }
   ```

2. **Retrieve a Specific Configuration**:

   To view details of a specific configuration, specify the configuration’s ID:

   ```powershell
   $configId = "<YourConfigID>"
   $config = Get-MgDeviceManagementDeviceConfiguration -DeviceConfigurationId $configId
   Write-Host "Configuration Name: $($config.DisplayName)"
   Write-Host "Description: $($config.Description)"
   ```

3. **Assign a Configuration to a Group**:

   To assign a device configuration to a specific Azure AD group, use this command:

   ```powershell
   $assignment = @{
       "@odata.type" = "#microsoft.graph.deviceConfigurationAssignment"
       "target" = @{
           "groupId" = "<YourGroupID>"
       }
   }
   New-MgDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $configId -BodyParameter $assignment
   Write-Host "Configuration assigned to group."
   ```

   This command links a configuration policy to a group of users or devices, ensuring that policies are enforced according to your organizational requirements.

### Step 4: Managing Applications in Intune

Applications can also be managed directly through PowerShell, including adding, updating, and assigning apps.

1. **List All Applications**:

   ```powershell
   $apps = Get-MgDeviceAppManagementMobileApps
   $apps | ForEach-Object { Write-Host $_.DisplayName }
   ```

   This command retrieves a list of all apps currently managed by Intune, allowing you to check what’s available or assigned.

2. **Add a New Application**:

   Here’s an example of adding a Windows Line-of-Business (LOB) app. You’ll need the app package file path.

   ```powershell
   $app = @{
       "displayName" = "YourAppName"
       "isFeatured" = $false
       "largeIcon" = @{
           "@odata.type" = "microsoft.graph.mimeContent"
           "type" = "image/png"
           "value" = "Base64EncodedIcon"
       }
       "publisher" = "YourPublisher"
       "isRequired" = $true
   }
   New-MgDeviceAppManagementMobileApps -BodyParameter $app
   Write-Host "Application added."
   ```

3. **Assign an App to a Group**:

   To assign an app to an Azure AD group, specify the app and group IDs:

   ```powershell
   $appId = "<YourAppID>"
   $groupId = "<YourGroupID>"
   New-MgDeviceAppManagementMobileAppAssignment -MobileAppId $appId -BodyParameter @{
       "target" = @{
           "groupId" = $groupId
       }
   }
   Write-Host "App assigned to group."
   ```

### Summary of Common Intune Management Commands

Here’s a quick reference for commands covered:

- **Devices**: `Get-MgDeviceManagementManagedDevice`, `Invoke-MgDeviceManagementManagedDeviceRestart`, `Invoke-MgDeviceManagementManagedDeviceWipe`
- **Configurations**: `Get-MgDeviceManagementDeviceConfiguration`, `New-MgDeviceManagementDeviceConfigurationAssignment`
- **Applications**: `Get-MgDeviceAppManagementMobileApps`, `New-MgDeviceAppManagementMobileAppAssignment`

### Conclusion

With these foundational commands, you’re now equipped to automate and manage essential tasks in Intune. PowerShell’s flexibility gives you more control over your Intune environment, whether you're managing devices, enforcing configurations, or deploying applications.

This concludes the foundational series. In future posts, I’ll dive deeper into advanced Intune automation, troubleshooting, and other specialized tasks. Thanks for following along—happy scripting!
