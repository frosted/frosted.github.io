---
title: Getting Started with PowerShell for Intune - Connecting to Intune
date: 2024-10-27 19:03:00 +0500
categories: [Endpoint Management]
tags: [intune, powershell, graph]     # TAG names should always be lowercase
---

### Introduction

If you’re working with Microsoft Intune, automating tasks with PowerShell can make your life a lot easier. Before you can dive into creating scripts or managing Intune assets, you’ll need to set up a secure connection between PowerShell and your Intune environment. 

In this post, I’ll walk you through the step-by-step process of connecting to Intune using PowerShell, discuss the modules involved, and explain what’s happening behind the scenes.

### Why Connect to Intune with PowerShell?

Connecting to Intune with PowerShell is essential for automating tasks like device management, policy configuration, and generating reports. With a PowerShell connection, you gain control over your Intune environment, enabling efficient management at scale.

### Step 1: Install the Microsoft Graph PowerShell SDK

The **Microsoft Graph PowerShell SDK** is the bridge between PowerShell and Microsoft Intune. This SDK lets you connect to Microsoft Graph, which is where Microsoft exposes Intune APIs, among others. Here’s how to get it set up:

1. Open PowerShell as an administrator.
2. Run the following command to install the Microsoft Graph PowerShell SDK module:

   ```powershell
   Install-Module Microsoft.Graph -Scope CurrentUser
   ```

   > **Note**: If prompted, approve the installation by typing "Y" or "A" to confirm.

3. After the installation completes, verify it by running:

   ```powershell
   Get-Module -ListAvailable Microsoft.Graph
   ```

   This should list the Microsoft Graph module, indicating it’s ready to use.

### Step 2: Import the Module and Authenticate

Once the SDK is installed, you’ll need to import the module into your session and authenticate to establish a secure connection with Intune.

1. **Import the Module**:

   ```powershell
   Import-Module Microsoft.Graph
   ```

2. **Sign In**:

   Run the following command to initiate a sign-in request:

   ```powershell
   Connect-MgGraph
   ```

   - A pop-up window will prompt you to enter your credentials.
   - Make sure you use an account with the appropriate permissions for Intune.

3. **Verify the Connection**:

   Once signed in, you can verify the connection by checking your account’s context:

   ```powershell
   Get-MgContext
   ```

   This command will display information about your session, including the user account and scopes (permissions) granted.

### Step 3: Grant Required Permissions

To manage Intune resources, you need to ensure your account has adequate permissions. In Microsoft Graph, these are typically set by your administrator and are associated with roles like **Intune Administrator** or **Global Administrator**.

#### Permissions Breakdown:

Some common permissions required for Intune management tasks include:

- **DeviceManagementManagedDevices.ReadWrite.All**: Read and write access to managed devices in Intune.
- **DeviceManagementConfiguration.ReadWrite.All**: Manage configurations and settings in Intune.

> **Tip**: If you don’t have the right permissions, contact your administrator to adjust your role in the Azure portal.

### Step 4: Test Your Connection to Intune

Now that you’re connected to Microsoft Graph with the proper permissions, let’s confirm that you can access Intune data.

1. **Retrieve Devices**: Run this command to retrieve a list of managed devices:

   ```powershell
   Get-MgDeviceManagementManagedDevice
   ```

   If successful, this command will return details of devices managed in Intune, such as device name, compliance state, and operating system.

2. **Retrieve Intune Configurations**:

   Similarly, you can retrieve information on device configurations with:

   ```powershell
   Get-MgDeviceManagementDeviceConfiguration
   ```

   These results confirm that your connection to Intune is active, and you can now proceed with managing configurations, policies, and devices.

### Behind the Scenes: How This Works

When you run `Connect-MgGraph`, PowerShell establishes a secure connection to Microsoft Graph, the API gateway for Microsoft 365 and Intune. Here’s a quick breakdown of how this connection works:

- **Authentication**: The Microsoft Graph SDK uses OAuth 2.0 to authenticate you via a secure token. Once authenticated, you can access Intune resources based on the permissions assigned to your account.
- **Microsoft Graph API Calls**: Commands like `Get-MgDeviceManagementManagedDevice` call the Graph API to retrieve Intune data. The SDK abstracts these API calls, allowing you to focus on tasks without needing in-depth API knowledge.

### Troubleshooting Common Issues

1. **Module Not Found**: If you get an error saying `Microsoft.Graph` module isn’t found, ensure that you installed it in the current PowerShell session by running `Install-Module Microsoft.Graph` as shown above.

2. **Permissions Errors**: If you encounter errors when trying to retrieve data (e.g., “Insufficient privileges”), verify that you have the necessary permissions.

3. **Network and Firewall Restrictions**: In corporate environments, network restrictions might prevent the connection. Make sure your environment allows access to Microsoft Graph endpoints.

### Conclusion

Connecting to Intune with PowerShell is your first step toward automating tasks and managing Intune more efficiently. With this setup, you’re now ready to explore a wide range of automation possibilities.

Stay tuned for the next post, where I’ll show you how to automate specific Intune management tasks with PowerShell, starting with device cleanup scripts and more!

With these basics in place, you’re equipped to dive into PowerShell automation for Intune. Don’t hesitate to reach out or comment if you run into any issues or have questions!

