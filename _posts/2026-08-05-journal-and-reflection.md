---
title: Daily Work Journal and Reflection
date: 2026-08-05 09:00:00 +0500
encrypted: true
hidden: true
feed: false
categories: [Private]
tags: [journal]
---

<!--

> **💡 HOW TO USE THIS JOURNAL:**
> 1. Complete this every day 5-10 minutes before logging off.
> 2. Keep entries in reverse chronological order (paste new dates at the very top).
> 3. Limit tomorrow's priorities strictly to 3 items to avoid burnout.
> 4. At the end of the week, reflect on accomplishments.

---Copy and paste region

#### This week's Accomplishments & Wins
* [Insert concrete win or major completed milestone from today]
* [Insert positive feedback received, a breakthrough, or a roadblock cleared]
* [Insert a minor task you are proud of finally wrapping up]

### [Date: Wednesday, August 5, 2026]

#### Running Daily Log
* [Quick bullet on internal/external meetings held and key outcomes]
* [Notes on ongoing deep-work tasks, active research, or documentation edits]
* [Decisions made, minor conversations, or raw ideas to remember later]

#### Today's Top Priorities
1. **[Priority]** - Crucial, non-negotiable morning focus item.
2. **[Priority]** - Secondary actionable task or follow-up.
3. **[Priority]** - Quick administrative win or meeting preparation task.
---End Copy and paste region
-->

## The Four Quadrants Prioritization (Impact vs. Effort)

<!--
🟢 **Quick Win** (Do First) 
🟡 **Fill-in** (Do Later)
🔵 **Major Project** (Plan)
🔴 **Thankless Task** (Drop)

| Impact \ Effort | **1** | **2** | **3** | **4** | **5** |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **1** | 🔵 **1.0** | 🔴 **0.5** | 🔴 **0.3** | 🔴 **0.2** | 🔴 **0.2** |
| **2** | 🟢 **2.0** | 🔵 **1.0** | 🔴 **0.7** | 🔴 **0.5** | 🔴 **0.4** |
| **3** | 🟢 **3.0** | 🔵 **1.5** | 🔵 **1.0** | 🔴 **0.8** | 🔴 **0.6** |
| **4** | 🟢 **4.0** | 🟢 **2.0** | 🔵 **1.3** | 🔵 **1.0** | 🔴 **0.8** |
| **5** | 🟢 **5.0** | 🟢 **2.5** | 🔵 **1.7** | 🔵 **1.2** | 🔵 **1.0** |

New Line:
| **** |  |  | **** |  |
-->


| Task / Feature | Impact (1-5) | Effort (1-5) | Priority Score | Quadrant / Action |
| :--- | :---: | :---: | :---: | :--- |
| **Self-Service VPN Client Deployment** | 4 | 2 | **2.0** | 🟢 **Quick Win** (Do First) |
| **User Assignment in TS** | 2 | 1 | **2** | 🟢 **Quick Win** (Do First) |
| **Limit BSOD Export to 60 days** | 2 | 1 | **2.0** | 🟢 **Quick Win** (Do First) |
| **Recast Patching** | 5 | 4 | **1.2** | 🔵 **Major Project** (Plan) |
| **Windows Patching Review** | 3 | 3 | **1.0** | 🔵 **Major Project** (Plan) |
| **Chrome Deployment** | 3 | 2 | **1.5** | 🔵 **Major Project** (Plan) |
| **PXE Boot Failures** | 3 | 3 | **1.0** | 🔵 **Major Project** (Plan) |
| **Remediate and Replace Deprecated MDT Integration** | 4 | 4 | **1.0** | 🔵 **Major Project** (Plan) |
| **Replace Legacy Software Install** | 5 | 4 | **1.2** | 🔵 **Major Project** (Plan) |
| **Self-Service Remediation Tools** | 5 | 4 | **1.2** | 🔵 **Major Project** (Plan) |
| **Functional Folder Structure and Naming Conventions for Device Collections** | 4 | 4 | **1.0** | 🔵 **Major Project** (Plan) |
| **BSOD Repo Cleanup** | 1 | 2 | **0.5** | 🔴 **Thankless Task** (Drop) |
| **Finish TL Migration Performance Testing** | 1 | 2 | **0.5** | 🔴 **Thankless Task** (Drop) |
| **MECM Content Distribution Strategy** | 2 | 3 | **0.7** | 🔴 **Thankless Task** (Drop) |


## 2026

#### This week's Accomplishments & Wins
* [Insert concrete win or major completed milestone from today]
* [Insert positive feedback received, a breakthrough, or a roadblock cleared]
* [Insert a minor task you are proud of finally wrapping up]

### [Date: Thursday, August 20, 2026]

#### Running Daily Log
* [Quick bullet on internal/external meetings held and key outcomes]
* [Notes on ongoing deep-work tasks, active research, or documentation edits]
* [Decisions made, minor conversations, or raw ideas to remember later]

#### Today's Top Priorities
1. **[Priority 1]** - write proposal to suppress all notifications (except restarts) for software updates
2. **[Priority 1]** - Fix error 0x1(1) in Recast deployments
3. **[Priority 3]** - Check that partner's system to see if it's compliant now

### [Date: Wednesday, August 19, 2026]

#### Running Daily Log
* Contact by Service Desk reporting the repair option in the Global Protect deployment results is missing the portal address.  This is now fixed
* Service Desk also reporting that a user who's system was fixed last week, found the deployment running again this morning.  I don't think this is possible without someone initiating the deployment.
* At 1pm I was asked to investigate why one lawyer's Windows updates failed.  It took nearly 3 hours of my time to report on what was missing, possible root causes, and work on remediation.  I'm still not clear that this was actually critical, but I do feel this was a poor use of my time.  I asked Dave why this was so critical, I was told that this is the "culture" here.  The only thing that is coming out of this is the realization that the software updates are being deployed with all notifications on.  I will propose that this change as this is a call driver.  Dave agrees.

#### Tomorrow's Top 3 Priorities
1. **[Priority]** - write proposal to suppress all notifications (except restarts) for software updates
2. **[Priority]** - Check that partner's system to see if it's compliant now
3. **[Priority]** - Fix error 0x1(1) in Recast deployments

### [Date: Tuesday, August 18, 2026]

#### Running Daily Log
* Helped service desk with another VPN issue.  This is becoming a daily occurance.
* Reacast in QA
  * Removed
    * Setting > Installation command: `powershell.exe -ExecutionPolicy Bypass -File ".\RecastAM\Invoke-AppDeployToolkit.ps1" -DeploymentType Install -DeployMode Interactive`
    * Setting > Uninstallation command: `powershell.exe -ExecutionPolicy Bypass -File ".\RecastAM\Invoke-AppDeployToolkit.ps1" -DeploymentType Uninstall -DeployMode Interactive`
  * Replaced with
    * Setting > Installation command: `.\RecastAM\Invoke-AppDeployToolkit.exe -DeploymentType Install -DeployMode Interactive`
	* Setting > Uninstallation command: `.\RecastAM\Invoke-AppDeployToolkit.exe -DeploymentType Uninstall -DeployMode Interactive`
  * This failed with 0x1(1) error.

#### Tomorrow's Top 3 Priorities
1. **[Priority]** - Fix error 0x1(1) in Recast deployments
2. **[Priority]** - Modify BSOD report to only send data from the past 60 days
3. **[Priority]** - User assignment script in the TS (Naim)

### [Date: Monday, August 17, 2026]

#### Running Daily Log
* Finished Global Protect 6.2.8-223 package revision, adding options for reinstall and repair.
  * Update in prod
  * We should put this in QA
* Requested Recast license for QA... and received.  

#### Tomorrow's Top 3 Priorities
1. **[Priority]** - Recast in QA, organize effort for presentation next week
2. **[Priority]** - Finish TL migration performance testing capture
3. **[Priority]** - Image update: test changes
4. **[Priority]** - Copy Global Protect deployment to QA

### [Date: Wednesday, August 13, 2026]

#### Running Daily Log
* Notes for meeting with Dave:
  * Tasks (this week)
    * TL migration performance testing
      * script completed
      * gathering baseline from Dexter's test system (pre,co-exist,post)
    * BSOD folder clean-up (26GB)
      * code ready to add to BSOD automation
    * PXE boot issues
      * tested without WDS, still not fixed
      * planning change to remove DHCP options for discussion with Bill and Henry
    * BSOD Tickets
      * ~~deploy full memory dumps configuration~~
      * ~~test configuration~~
      * ~~send memory.dmp, if approved~~
    * Knowledge transfer: TS and image update
      * working on getting access (Mo)
    * GlobalProtect deployment
      * Make a script available to fix service
  * Tasks (started)
    * Priority 1
    * Priority 2
      * Recast
        * Planning prod implementation for SCR
        * POC for support meeting
        * Contact Recast to extend QA license
      * Modernize OSD (replace MDT integration in TS)
        * Working with Dexter on testing
      * MECM Content Distribution Strategy Using DP Groups
        * Need to discuss with Bill
        * Script (1st draft) created to 
          * identify content distribution
          * create distribution groups
          * re-distribute content based on current assignments
        * Still need to test and document
      * Replace Fanny's Software Install solution
    * Priority 3
      * Reporting dashboard for WHEAs
      * Functional Folder Structure and Naming Conventions for Device Collections
        * Need to discuss with Bill
        * Once a structure is agreed on, we'll make changes in QA
        * Need to develop
          * Script to capture all objects and paths
          * Script to create new structure
          * Script to move objects 
          * Script to rollback
      * POC: Alerts to Telegram
        * This was done, just put a demo together    
  * Tasks (not started)
    * Options to replace Software Install
    * User Assignment - add for new/replacement devices
  

#### Tomorrow's Top 3 Priorities
1. **[Priority]** - Show & Tell
2. **[Priority]** - Secondary actionable task or follow-up.
3. **[Priority]** - Quick administrative win or meeting preparation task.

#### This week's Accomplishments & Wins
* An issue that blocked network access required a the VPN client upgrade. I quickly built and deployed a fix package for affected users. This update resolved the connection issue and provided a smooth, branded experience using PSADT templates. The incident proved my ability to handle urgent problems and deliver results under pressure.

### [Date: Wednesday, August 12, 2026]

#### Running Daily Log
* Meeting with Dave
  * Performance concerns regarding lack of transparency with team, attendance, responsiveness (teams, e-mail), having to be chased for updates - specifically for tasks from Dave.
  * Plan to address concerns:
    * Transparency
	  * Prepare for one-on-one with all tasks currently on my plate so things can be prioritized or re/unassigned
	  * Use these logs to send updates to team on what I'm doing
	* Attendance
	  * 3 days/week, this has to be planned and communicated at work and at home.  
	* Responsiveness
	  * I'm guessing this is more an issue with e-mail. Just keep this in mind, because I'm not sure that this is a problems
	* Any asks from Dave will stay on the priority list until it's done
* Task sequence updates will be handled by Dexter, currently working with Mohammad to get access
* got a full memory dump captured on hmalik's device, waiting on Dave to get approval before sharing with MSFT
* o=wF*t1q_cE|!A$<5)/^f
  

#### Tomorrow's Top 3 Priorities
1. **[Priority]** - 
2. **[Priority]** - Follow-up on access to Microsoft 365 Admin center product downloads (Mohammad)
3. **[Priority]** - Update DB on TL testing

### [Date: Tuesday, August 11, 2026]

#### Running Daily Log
* Configured the following users for complete memory dumps on any future BSODs
  * ookanga
  * gantonopoulos
  * aliu
  * hmalik
* Tested complete capture on my system by triggering a BSOD, which resulted in c:\windows\memory.dmp
  ```cmd
  REM this triggers a CRITICAL_PROCESS_DIED or CRITICAL_PROCESS_ENDED BSOD
  REM I ran this as SYSTEM
  taskkill /f /im svchost.exe
  ```
* SCR 14270 is complete. The Global Protect client v6.2.8-c223 is now available for all laptops via Software Center.
* modified performance baseline script to call a single phase 

#### Tomorrow's Top 3 Priorities
1. **[Priority]** - Continue TL performance baseline testing
2. **[Priority]** - Patch image 
3. **[Priority]** - 

### [Date: Monday, August 10, 2026]

#### Running Daily Log
* Patch week, image update script needs to be fixed.  There's a process we follow that is in place for Edward's benefit - we should review this.
* As a result of the  migration over the weekend, the baseline VPN version was somehow reset, deploying a new client version to everyone on connection.  This alone may not have been an issue, but I believe it is because we had a script to install an older version.  The install itself is not the issue, but the removal the PanGPS service could havebeen the culprit in many cases.  I modified our deployment to uninstall the current version and install the new version.  It's the same approach I want us to move away from , but in this case, we'll need to go this route.
* Naim fixed issues with his image update script.  He worked on it all day

#### Tomorrow's Top 3 Priorities
1. **[Priority]** - ~~Test script to enable complete memory dump on remote systems~~
2. **[Priority]** - Continue TL performance baseline testing
3. **[Priority]** - ~~Discuss user experience of GP deployment~~

### This Week's Accomplishments & Wins
* I started this daily journal, added it to my blog and encrypted it

### [Date: Friday, August 7, 2026]

#### Running Daily Log
* Marv questioning the WDS boot screen.  I reviewed the logs and everything looks good. The device is successfully PXE booting and receiving the task sequence. The PXE Responder is handling the requests, so I don't have any concerns based on what we're seeing so far - at least as far as who is steering the PXE requests.  Even when PXE Responder is enabled, wdsmgfw.efi is still used during parts of the PXE process.  So seeing a "WDS Boot Manager" screen does not automatically mean WDS is installed or handling PXE.  It's weird.
* Marv tested a system that couldn't PXE boot in QA.  Even with PXE responder, the system still fails to PXE boot.  
* Pre baseline captured on two systems.  Monday we will continue with c-existence and post capture.

#### Tomorrow's Top 3 Priorities
1. **[Priority]** - Test script to enable complete memory dump on remote systems
2. **[Priority]** - Continue TL performance baseline testing
3. **[Priority]** - Send update to MSFT regarding Secure Boot testing

### [Date: Thursday, August 6, 2026]

#### Running Daily Log
* ThreatLocker
  * Finalized the PowerShell performance baseline script using verified process mappings and validated the metrics; we are now ready to begin migration testing.
  * Dexter preparing his system for testing

#### Tomorrow's Top 3 Priorities
1. **[Priority]** - Test script to enable complete memory dump on remote systems
2. **[Priority]** - ~~Secure boot testing in QA~~
3. **[Priority]** - ~~Start TL migration performance baseline testing~~

### [Date: Wednesday, August 5, 2026]

#### Running Daily Log
* Team planning meeting 
  * DB brought up the need to retire the InstallSoftware.ps1 script.  As expected, push-back from FL.  NC suggested we retain the data stored in JSON files for some sort of automation in the future.  I don't really understand the logic here, but we can keep it in mind.  Personally, I don't want to have to maintain this file.
  * DB eluded to there needing to be changes to the way we handle QA testing - mentioning the bottleneck in the way we do things today.
* ThreatLocker project meeting
  * DB asked for performance metrics across all the three stages of this deployment.
  * Deployment stages:
    * Pre-switch (Carbon Black baseline)
    * Co-existence (ThreatLocker in Learning Mode)
    * Post-switch (ThreatLocker Enforce)
  * Due by EOW
* PXE Responder has been enabled in QA to mitigate the PXE boot issues observed after Microsoft's Secure Boot certificate updates. We are currently validating the results, and regardless of the outcome, this change modernizes our PXE boot configuration.

#### Tomorrow's Top 3 Priorities
1. **[Priority]** - Test script to enable complete memory dump on remote systems
2. **[Priority]** - ~~Performance metering script~~
3. **[Priority]** - ~~Run final secure boot baseline report for Dave~~