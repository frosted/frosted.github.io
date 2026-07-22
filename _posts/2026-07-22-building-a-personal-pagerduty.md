---
title: Building a Personal PagerDuty - Send PowerShell Script Alerts to Telegram
date: 2026-07-22 15:14:00 +0500
categories: [API Integrations]
tags: [powershell, api]     # TAG names should always be lowercase
---

### Introduction

I used to carry a corporate-issued phone glued to my hip. It buzzed, chimed, and demanded my attention every time a server coughed. Recently, I transitioned to a new role where my responsibilities do not require a corporate device. It was a massive win for my work-life balance, but old habits die hard.

In this new environment, we have a lot of automated scripts running on schedules, but we have zero alerting around them. Even when a script does have alerting built-in, it sends an email, which does me absolutely no good if I am away from my laptop and don't have a work phone to check it. I missed the peace of mind that came with knowing I would be notified if my scheduled automation tasks failed.

If you have ever set up a scheduled task, like the automated Intune Device Clean-up Script from my last post, and hated the blind spot of not knowing if it ran properly, this one is for you. Today, we are going to build our own personal alert hub. 

### Why Telegram Instead of WhatsApp?

My first idea was WhatsApp, but automating WhatsApp for personal alerting is usually expensive and/or restrictive. 

Telegram is a cleaner fit for this scenario:

- Free for personal use
- Fast setup with no business onboarding
- Simple HTTP API that works great from PowerShell
- Reliable delivery to your phone even when you are away from your laptop

### Step 1: Create Your Telegram Bot

1. Open Telegram and search for `@BotFather`.
2. Run `/newbot` and follow the prompts for bot name and username.
3. Copy the bot token that BotFather returns.
4. Open your new bot chat and click **Start**.

### Step 2: Get Your Personal Chat ID

1. Search for `@chatid_echo_bot` (or any trusted chat ID bot).
2. Click **Start**.
3. Copy your numeric chat ID.

You now have the two values required for alerting:

- Bot token
- Chat ID

### Step 3: Set the Required Environment Variables

Before using the function, set both environment variables in PowerShell.

For the current PowerShell session only:

```powershell
$env:TELEGRAM_BOT_TOKEN = '123456789:AAExampleTokenFromBotFather'
$env:TELEGRAM_CHAT_ID   = '123456789'
```

To persist them for your user profile (available in new sessions):

```powershell
[System.Environment]::SetEnvironmentVariable('TELEGRAM_BOT_TOKEN', '123456789:AAExampleTokenFromBotFather', 'User')
[System.Environment]::SetEnvironmentVariable('TELEGRAM_CHAT_ID', '123456789', 'User')
```

After setting persistent variables, close and reopen PowerShell so the new session can read them.

### Step 4: Add Alerting to Your Scheduled Script

Below is a reusable function you can drop into any scheduled PowerShell script. It sends a success notification when the script completes, and a failure notification with the error message if it crashes.

```powershell
function Send-PSETAlert {
    <#
    .SYNOPSIS
        Sends an alert message to a Telegram chat.

    .DESCRIPTION
        Sends a message using the Telegram Bot API. You can pass the bot token and
        chat ID directly, or rely on environment variables TELEGRAM_BOT_TOKEN and
        TELEGRAM_CHAT_ID.

    .PARAMETER Message
        The alert text to send to Telegram.

    .PARAMETER BotToken
        Telegram bot token. Defaults to environment variable TELEGRAM_BOT_TOKEN.

    .PARAMETER ChatId
        Telegram chat ID (user, group, or channel). Defaults to environment variable
        TELEGRAM_CHAT_ID.

    .PARAMETER ParseMode
        Optional Telegram parse mode. Supported values: None, Markdown, MarkdownV2, HTML.

    .EXAMPLE
        Send-PSETAlert -Message 'Scheduled task completed successfully.'

    .EXAMPLE
        Send-PSETAlert -Message '*Warning:* deployment failed.' -ParseMode Markdown
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$BotToken =  $env:TELEGRAM_BOT_TOKEN,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ChatId = $env:TELEGRAM_CHAT_ID,

        [Parameter()]
        [ValidateSet('None', 'Markdown', 'MarkdownV2', 'HTML')]
        [string]$ParseMode = 'None'
    )

    process {
        if ([string]::IsNullOrWhiteSpace($BotToken)) {
            throw 'Bot token is required. Pass -BotToken or set TELEGRAM_BOT_TOKEN.'
        }

        if ([string]::IsNullOrWhiteSpace($ChatId)) {
            throw 'Chat ID is required. Pass -ChatId or set TELEGRAM_CHAT_ID.'
        }

        $uri = "https://api.telegram.org/bot$BotToken/sendMessage"
        $body = @{
            chat_id = $ChatId
            text    = $Message
        }

        if ($ParseMode -ne 'None') {
            $body['parse_mode'] = $ParseMode
        }

        try {
            Write-Verbose "Sending Telegram alert to chat '$ChatId'."
            $response = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ErrorAction Stop

            if (-not $response.ok) {
                $description = if ($response.description) { $response.description } else { 'Unknown Telegram API failure.' }
                throw "Telegram API returned a failure response: $description"
            }

            return $response
        }
        catch {
            $message = "Failed to send Telegram alert. $($_.Exception.Message)"
            $exception = New-Object System.InvalidOperationException($message, $_.Exception)
            $errorRecord = New-Object System.Management.Automation.ErrorRecord($exception, 'SendPSETAlertFailed', [System.Management.Automation.ErrorCategory]::OperationStopped, $ChatId)
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }
}
```

### Step 5: Use the Function

Once the function is loaded into your session (or script), you can send alerts like this:

```powershell
# Basic message (uses TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID from environment variables)
Send-PSETAlert -Message 'Scheduled task completed successfully.'

# Markdown formatted message
Send-PSETAlert -Message '*Warning:* Intune cleanup failed on server APP01.' -ParseMode Markdown
```

Inside your scheduled script, call it in your `try/catch` block:

```powershell
try {
    # Your task logic
    Send-PSETAlert -Message '*Success:* Nightly cleanup completed.' -ParseMode Markdown
}
catch {
    Send-PSETAlert -Message "*Failure:* Nightly cleanup crashed.`nError: $($_.Exception.Message)" -ParseMode Markdown
    throw
}
```

### Step 6: Test Before Scheduling

Before wiring this into Task Scheduler, run the script manually.

1. Run once with normal logic to confirm a success alert.
2. Force a failure (for example, by temporarily using an invalid command) to confirm error alerting.
3. Review the Telegram message format and adjust text to match your preference.

This quick validation prevents silent failures later when the script runs unattended.

### Example Result

Here is what a real Telegram notification looks like:

![telegram notification](/assets/img/2026-07-22_screenshot112800.png)

### Troubleshooting Tips

1. **No message received**: Confirm you clicked **Start** in the bot chat and that the chat ID is correct.
2. **401/403 errors**: Re-check the bot token and regenerate it from BotFather if needed.
3. **Script runs but no alerts**: Verify outbound HTTPS access to `api.telegram.org` from the machine running the task.
4. **Graph command failures**: Confirm module installation and Graph scopes for device read/write operations.

### Conclusion

This function gives you a lightweight personal alerting system without depending on email, paid messaging platforms, or a full incident-management stack. If a scheduled script succeeds, you know right away. If it fails, you get the error instantly on your phone.

For admin workflows like Intune cleanup, that visibility is often the difference between proactive maintenance and discovering issues days later.

Thanks for reading, and happy automating!