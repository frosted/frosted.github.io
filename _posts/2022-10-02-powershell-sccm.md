---
title: SCCM & PowerShell - Getting Started
date: 2022-10-02 00:08:00 +0500
categories: [Endpoint Management]
tags: [configmgr, PowerShell]     # TAG names should always be lowercase
---
In this article I hope to show you how to:
- Connect to your site via Windows PowerShell (console way)
- Create a function to connect to site

Before that, our commandments
- Thou shallt not RDP and work from a site server
- Thou shallt not RDP and work from a system server
- Thou shallt not RDP and work from a SQL server
- Thou shallt not run code untested (-WhatIf)

## The way of the console
This is probably the easiest way to do it if you already have the console open and the way most people do it.  You will of course need to open the console:
1. Select the upper-left white arrow 
2. Choose Connect via Windows PowerShell ISE
3. Once PowerShell ISE loads, you'll notice you're at a prompt with your site code.

## The way I do it
I don't always have the console open, but my PowerShell console is always open.  I can connect to site as fast or faster than you can through the console.  At the end of the day, that why I do things in PowerShell - to do more through less effort.  You ##could## just take the script that already resides in your environment (it's the script that runs when you follow the console way above), or you can use the following code:

`Function Connect-MECM
{
    #paste code here
}`
You can leverage this function in several ways.
1. Dot-source then call the function (meh)
2. Import PowerShell module in PowerShell profile (yeah)

### The way of dot-sourcing
To dot-source a script is simple. From your PowerShell console, type a dot (.) and a space before the your script path.
```
# Assuming my script was saved under c:\_code\
PS C:\Users\frosted> . C:\_code\Connect_MECM
```
All functions and variables created in dot-sourced script are now in the current scope.

> Tip: dot-source functions allows you to easily call the code again.  In this case, let's say you had switch your current working location from site to the system drive, you can easily reconnect to your CMSite drive by calling the `Connect_MECM` function.

### The way I do it
I have functions in a custom module that are always available to me because I've imported them in my Windows PowerShell Profile using the `Import-Module` cmdlet. 
```
# Assuming your current location is where the psm1 file is saved
PS C:\_code> . C:\_code\MECM.psm1
```
This is a lot to digest, so I'll go over this in a future article.  For now, know that this option exists and start to think of ways you might want to group your functions into a module for importing at a later date.

## What Now?
You are now connected to your site via PowerShell.  Now you can leverage the power of the ConfigurationManager module.  Before we get into the nitty-gritty, let's run a simple command.
Run this code to return the device object for your system, assuming your system is managed.
```
PS C:\Users\frosted> Get-CMDevice -Name $env:ComputerName
```



