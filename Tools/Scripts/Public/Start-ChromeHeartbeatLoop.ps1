#Requires -Version 7.0
#Requires -Modules Selenium

param(
    [string]$Url = "https://gemini.google.com/app/46de25017f04b5d5",
    [string]$DriverFolder = "C:\WebDriver",
    [string]$UserDataDirectory = "C:\Users\sixil\AppData\Local\Google\Chrome\User Data"
)

# Add the WebDriver's folder to the PATH for this session.
$env:PATH = "$DriverFolder;$env:PATH"

Write-Host "IMPORTANT: Please close all other Chrome browser windows before continuing." -ForegroundColor Yellow
Read-Host "Press Enter to start the script..."

try {
    # --- CORRECTED: Configure Chrome Arguments as a Hashtable ---
    # This format is what the Start-SeChrome command expects.
    $ChromeArguments = @{
        "binary" = "C:\Program Files\Google\Chrome\Application\chrome.exe" # The path you confirmed
        "args"   = @(
            "--user-data-dir=$UserDataDirectory",
            "--profile-directory=Default"
        )
    }
    
    Write-Host "Starting Chrome with your user profile..." -ForegroundColor Cyan
    
    # Pass the correctly formatted arguments to the -Arguments parameter
    $Driver = Start-SeChrome -Arguments $ChromeArguments

    Write-Host "Navigating to Gemini chat: $Url" -ForegroundColor Cyan
    Enter-SeUrl -Url $Url -Driver $Driver

    Write-Host "Page loading... Please wait 15 seconds." -ForegroundColor Cyan
    Start-Sleep -Seconds 15
    Write-Host "Page loaded. Starting heartbeat loop..." -ForegroundColor Green

    # --- Main Heartbeat Loop ---
    while ($true) {
        $timestamp = (Get-Date).ToUniversalTime().ToString('o')
        $heartbeatMessage = "[HEARTBEAT @ $timestamp]"

        try {
            # Find and interact with page elements
            $inputBox = Find-SeElement -Driver $Driver -By CssSelector 'div[role="textbox"]' -Timeout 10
            $sendButton = Find-SeElement -Driver $Driver -By CssSelector 'button[aria-label*="Send"]' -Timeout 10

            if ($inputBox -and $sendButton) {
                Write-Host "($((Get-Date).ToString('T'))) Sending heartbeat: $heartbeatMessage" -ForegroundColor Yellow
                Send-SeKeys -Element $inputBox -Keys $heartbeatMessage
                Start-Sleep -Seconds 2
                Click-SeElement -Element $sendButton
            }
        } catch {
            Write-Warning "An error occurred during the heartbeat cycle: $_"
            Enter-SeUrl -Url $Url -Driver $Driver; Start-Sleep -Seconds 15
        }

        Write-Host "Heartbeat sent. Waiting for 30 minutes..." -ForegroundColor Cyan
        Start-Sleep -Seconds 1800
    }

} catch {
    Write-Error "A critical error occurred: $_"
} finally {
    Write-Host "Stopping Selenium driver and closing the browser..." -ForegroundColor Magenta
    if ($Driver) {
        Stop-SeDriver -Driver $Driver
    }
}