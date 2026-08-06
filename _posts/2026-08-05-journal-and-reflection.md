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

#### Tomorrow's Top 3 Priorities
1. **[Priority 1]** - Crucial, non-negotiable morning focus item.
2. **[Priority 2]** - Secondary actionable task or follow-up.
3. **[Priority 3]** - Quick administrative win or meeting preparation task.
---End Copy and paste region
-->
## 2026

### This Week's Accomplishments & Wins
* I started this daily journal, added it to my blog and encrypted it

### [Date: Thursday, August 6, 2026]

#### Running Daily Log
* [Quick bullet on internal/external meetings held and key outcomes]
* [Notes on ongoing deep-work tasks, active research, or documentation edits]
* [Decisions made, minor conversations, or raw ideas to remember later]

#### Tomorrow's Top 3 Priorities
1. **[Priority 1]** - Crucial, non-negotiable morning focus item.
2. **[Priority 2]** - Secondary actionable task or follow-up.
3. **[Priority 3]** - Quick administrative win or meeting preparation task.

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
1. **[Priority 1]** - Test PXE responder and secure boot issue.
2. **[Priority 2]** - Performance metering script.
3. **[Priority 3]** - Run final secure boot baseline report for Dave