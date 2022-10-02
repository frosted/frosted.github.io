---
title: SCCM & PowerShell - Getting Started
date: 2022-10-02 00:08:00 +0500
categories: [Endpoint Management]
tags: [configmgr, PowerShell]     # TAG names should always be lowercase
---

In this article I hope to show you how to:
- Connect to your site via Windows PowerShell (console way)
- Create a function to connect to site

## The way of the console
This is probably the easiest way to do it if you already have the console open and the way most people do it.  You will of course need to open the console:
1. Select the upper-left white arrow 
2. Choose Connect via Windows PowerShell ISE
3. Once PowerShell ISE loads, you'll notice you're at a prompt with your site code.

## The way I do it
I don't always have the console open, but my PowerShell console is always open.  I can connect to site as fast or faster than you can through the console.  At the end of the day, that why I do things in PowerShell - to do more through less effort.  You ##could## just take the script that already resides in your environment (it's the script that runs when you follow the console way above), or you can use the following code:
(add script from github here)
`Function Connect-MECM
{
    #paste code here
}`
You can leverage this function in several ways.
1. Dot-source then call the function (meh)
2. Import PowerShell module in PowerShell profile (yeah)

### The way of dot-sourcing

### The way I do it

You are now connected to your site via PowerShell.  Now you can leverage the power of the ConfigurationManager module.

