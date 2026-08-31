---
title: Scaling Your Scripts - Version Control and Collaboration with Azure DevOps
date: 2026-08-24 09:00:00 +0500
categories: [Intune DevOps]
tags: [powershell, graph, intune, api, devops, pester]     # TAG names should always be lowercase
---

### Introduction

In the last post, we covered [Configuration Profile Version Control]({% post_url 2026-07-28-configuration-profile-version-control %}) and why exporting Intune configurations to JSON gives you an operational undo button.

The next step is bigger than backups: collaboration.

When your scripts grow from one-admin utilities into team-owned automation, you need more than a folder of `.ps1` files. You need structure, review, and repeatable delivery. This is where Azure DevOps becomes a full collaboration suite for IT Ops.

If your goal is making ops easy, this shift matters: fewer production surprises, faster onboarding, and cleaner automation lifecycle management.

### Why Azure DevOps for Scripted Ops?

Azure DevOps gives your team a connected workflow for code, reviews, and pipelines:

- Azure Repos for source control
- Pull Requests for peer review
- Pipelines for automation and validation
- Work items to tie technical changes back to operational intent

In plain terms, it turns script changes into auditable, repeatable operations.

### VS Code + Git: The Day-to-Day Setup

For most admins, VS Code plus Git is the fastest way to modernize PowerShell work.

1. Install Git locally and sign in to Azure DevOps.
2. Clone your repository into a working folder.
3. Open the repository in VS Code.
4. Use the Source Control view to stage, commit, and sync changes.

Example setup from a PowerShell terminal:

```powershell
git clone https://dev.azure.com/<org>/<project>/_git/<repo-name>
Set-Location .\<repo-name>
code .
```

Why this is better than loose `.ps1` files:

- **History**: Every change is tracked.
- **Traceability**: You can answer who changed what and why.
- **Recovery**: Roll back safely when needed.
- **Team scale**: Multiple admins can work in parallel without overwriting each other.

### Collaboration Workflow: Branches + PRs

A simple branching model works well for most Intune automation teams.

### Branching Strategy

- Keep `main` clean and deployable.
- Create short-lived branches for changes using `feature/` or `fix/` prefixes.
- Merge to `main` only through Pull Requests.

Examples:

- `feature/intune-cleanup-alerting`
- `feature/graph-config-policy-export`
- `fix/device-cleanup-null-lastcontact`

This protects your production path while allowing fast iteration.

### Pull Request Process

A practical PR flow:

1. Create your feature branch.
2. Implement script updates and tests.
3. Push branch and open a PR in Azure DevOps.
4. Request review from at least one teammate.
5. Address comments and re-run validations.
6. Merge only after approval and passing checks.

Why this helps before deployment to Intune:

- Catches logic bugs and edge cases
- Improves script readability and maintainability
- Reduces the chance of misconfigured policies or accidental deletions

A lightweight PR checklist can include:

- Scope is clear and limited
- Error handling is present
- Logging/output is useful for operations
- Pester tests are updated
- Change notes explain potential impact

### Automated Testing with Pester

Before merging, validate scripts with tests. Pester is the standard testing framework for PowerShell and is perfect for IT Ops automation.

For example, instead of testing a full destructive cleanup flow, test a pure function that identifies stale devices. This gives quick confidence without touching production objects.

Sample function (`scripts/Get-StaleIntuneDevices.ps1`):

```powershell
function Get-StaleIntuneDevices {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$Devices,

        [Parameter()]
        [int]$InactiveDays = 90
    )

    $cutoff = (Get-Date).AddDays(-$InactiveDays)

    return $Devices | Where-Object {
        $_.LastContact -lt $cutoff
    }
}
```

Basic Pester test (`tests/Get-StaleIntuneDevices.Tests.ps1`):

```powershell
. "$PSScriptRoot\..\scripts\Get-StaleIntuneDevices.ps1"

Describe 'Get-StaleIntuneDevices' {
    It 'returns only devices older than the inactivity threshold' {
        $devices = @(
            [pscustomobject]@{ DeviceName = 'Device-A'; LastContact = (Get-Date).AddDays(-120) }
            [pscustomobject]@{ DeviceName = 'Device-B'; LastContact = (Get-Date).AddDays(-10) }
            [pscustomobject]@{ DeviceName = 'Device-C'; LastContact = (Get-Date).AddDays(-95) }
        )

        $result = Get-StaleIntuneDevices -Devices $devices -InactiveDays 90

        $result.Count | Should -Be 2
        $result.DeviceName | Should -Contain 'Device-A'
        $result.DeviceName | Should -Contain 'Device-C'
        $result.DeviceName | Should -Not -Contain 'Device-B'
    }
}
```

Run tests locally before pushing:

```powershell
Invoke-Pester -Path .\tests
```

This is one of the highest-return habits in script reliability.

### Best Practices for Team-Scale Script Repos

1. **Commit messages**: Use clear, action-focused messages.
   - Example: `Add idempotent check before config profile creation`
2. **Branch naming**: Keep names consistent and searchable.
   - Example: `feature/intune-policy-json-import`
3. **Repository structure**: Separate scripts, tests, docs, and sample configs.

Recommended layout:

```text
/intune-devops
  /scripts
  /tests
  /configs
  /docs
  README.md
```

4. **Keep `main` releasable**: Never merge unreviewed changes.
5. **Document required Graph scopes**: Avoid permission guesswork during incidents.

### Conclusion

Version control gives us an undo button. Azure DevOps gives us a collaboration engine.

By combining VS Code + Git, disciplined branching, PR-based reviews, and Pester tests, Intune automation becomes safer, cleaner, and easier to scale across teams.

For admins focused on making ops easy, this is the transition from hero scripting to sustainable operations.  You're not just writing scripts anymore; you are building operational products your team can trust.

### References

- [Azure DevOps Documentation](https://learn.microsoft.com/azure/devops/?view=azure-devops)
- [Azure Repos and Branching Strategies](https://learn.microsoft.com/azure/devops/repos/git/git-branching-guidance?view=azure-devops)
- [Review Pull Requests in Azure Repos](https://learn.microsoft.com/azure/devops/repos/git/review-pull-requests?view=azure-devops)
- [Pester Documentation](https://pester.dev/)
