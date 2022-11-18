---
title: SCCM & PowerShell - Moving On
date: 2022-10-03 22:08:00 +0500
categories: [Endpoint Management]
tags: [configmgr, powershell]     # TAG names should always be lowercase
---
I'd like to start by going over a couple thing that I missed in the ([last article](2022-10-02-powershell-sccm.md)).  My connect funciton may be a little out-of-date for your environment (should still work though).  I'll update my connect function when I update my lab environment beyond 2111.  For more information, read [Get Started with Configuration Manager cmdlets](https://learn.microsoft.com/en-us/powershell/sccm/overview?view=sccm-ps).

> Updates: <br/>Starting in version 2103, the ConfigurationManager PowerShell module requires Microsoft .NET version 4.7.2 or later. <br/>Starting in version 2111, when you install the Configuration Manager console, the path to the module is now added to the system environment variable, PSModulePath. you can now import the module just by its name: `Import-Module ConfigurationManager`


- Find cmdlet
- Reference help
- 