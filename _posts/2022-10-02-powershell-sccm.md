---
title: SCCM & PowerShell - Getting Started
date: 2022-10-02 00:08:00 +0500
categories: [Endpoint Management]
tags: [configmgr, powershell, getting started]     # TAG names should always be lowercase
---
  In this series of how-to articles, I hope to share with you some of the first steps that got me excited about moving my operational efforts into a PowerShell console.  In no time, you'll be automating compliance reports, component health emails, complicated deployments from intake (e.g. csv) defining deployment parameters, collection creation, scheduling availabity and deadlines, user experience, etc.  If these steps are familiar to you, especially if you support a large environment, you're well aware of the hours it can take to set up a complicated deployment.  This can be reduced to minutes, all the while minimizing (if not eliminating) errors.   

> Tip: You do not need to do any of this from a server.  I've run into a lot of admins that like to do ConfigMgr work from the Site Server, or SQL work from the SQL Server.  I haven't heard a good reason yet that would prevent you from doing day-to-day operational work remotely, from your client system.  

In this article I hope to show you how to:
- Connect to your site via Windows PowerShell (console way)
- Create a reusable function to connect to site (code way)

## The way of the console
This is probably the easiest way to do it if you already have the console open (and the way most people do it), but it doesn't have to be the way we do things.  You will of course need to open the console...
1. Select the upper-left white arrow 
2. Choose Connect via Windows PowerShell ISE
3. Once PowerShell ISE loads, you'll notice you're at a prompt with your site code.

## The way I do it
I don't always have the console open, but my PowerShell console or VS Code is *always open*, so this eliminates the clicky steps for me.    At the end of the day, that's why I do things in PowerShell - to get more (results) for less (effort).  You *could* just take the script that already resides in your environment (it's the script that runs when you follow the console way above), or you can use the following code: [Connect_Functions.ps1](https://github.com/frosted/PoSH/blob/master/Connect_Functions.ps1)
```powershell
Function Connect-MECM
{    
    [CmdletBinding()]
    Param 
    (
        [Parameter(Mandatory=$false)][string]$ProviderMachineName=$Script:SMSProvider
    )
    Begin
    {
        Function Get-MECMSiteCode
        {

            Param 
            (
                [Parameter(Mandatory=$true)][string]$SMSProvider
            )

            $wqlQuery = “SELECT * FROM SMS_ProviderLocation”
            $a = Get-WmiObject -Query $wqlQuery -Namespace “root\sms” -ComputerName $SMSProvider
            $a | ForEach-Object {
                if($_.ProviderForLocalSite)
                    {
                        $script:SiteCode = $_.SiteCode
                    }
            }
            return $SiteCode
        }
    }
    Process
    {
        Try
        {
            # Site configuration
     
            $SiteCode = Get-MECMSiteCode -SMSProvider $ProviderMachineName

            # Customizations
            $initParams = @{}
            #$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
            #$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

            # Do not change anything below this line

            # Import the ConfigurationManager.psd1 module 
            if((Get-Module ConfigurationManager) -eq $null) {
                Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
            }

            # Connect to the site's drive if it is not already present
            if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
                New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
            }

            # Set the current location to be the site code.
            Set-Location "$($SiteCode):\" @initParams
        }
        Catch
        {
            Write-Error "$($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
    End
    {
        If ( (Get-Location | Select-Object -ExpandProperty Provider) -like '*CMSite*')
        {
            Write-Output 'Connection Successful'
        }
    }
}
```

You can leverage this function in several ways.
1. Dot-source then call the function (meh)
2. Import PowerShell module in PowerShell profile (yeah)

### The way of dot-sourcing
This is not persistent, so if you close your session, you will need to dot-source your script again.  To dot-source a script is simple. From your PowerShell console, type a dot (.) and a space before the your script path.
```powershell
# Assuming my script was saved under c:\_code\
. C:\_code\Connect_MECM
```

All functions and variables created in dot-sourced script are now in the current scope.

> Tip: dot-source functions allows you to easily call the code again.  In this case, let's say you had switch your current working location from site to the system drive, you can easily reconnect to your CMSite drive by calling the `Connect_MECM` function.

### The way I do it
I have functions in a custom module that are always available to me because I've imported them in my Windows PowerShell Profile using the `Import-Module` cmdlet. 
```powershell
# Assuming your current location is where the psm1 file is saved
. .\MECM.psm1
```

This is a lot to digest, so I'll go over this in a future article.  For now, know that this option exists and start to think of ways you might want to group your functions into a module for importing at a later date.

## What Now?
You are now connected to your site via PowerShell.  Now you can leverage the power of the ConfigurationManager module.  Before we get into the nitty-gritty, let's run a simple command.
Run this code to return the device object for your system, assuming your system is managed.
```powershell
Get-CMDevice -Name $env:ComputerName
```

Yeah, I know... so what, right?  Take a look at all the attributes in the device object returned and think about how you may be able to leverage this on a larger scale.  For instance, If you wanted to list systems missing the ConfigMgr client, you would run the following.
```powershell
Get-CMDevice -Fast | Where-Object IsClient -eq $false | Select-Object Name
```

In the next article, we'll look at doing some cool things with the ConfigurationManager module.  Until then, play around.  See what cmdlets are available.
```
Get-Command -Module ConfigurationManager
```

## Summary
This is just the tip of the iceberg.  If you're just starting out, my advice is to explore how to do everything in PowerShell.  Need to create a collection?  Do it in PowerShell.  Need to delete a device?  Do it in PowerShell.  It will be slow and painful at first, but you'll grow faster and more confident with daily exposure.  Make the commitment to yourself to replace mouse-clicks with code, you won't regret it. 




