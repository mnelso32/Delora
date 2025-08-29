#Requires -Version 7.0
#Requires -Modules Selenium

param(
    [string]$Url = "https://gemini.google.com/app/46de25017f04b5d5",
    [string]$DriverFolder = "C:\WebDriver",
    # --- UPDATED: Using a dedicated, separate profile for automation ---
    [string]$UserDataDirectory = "C:\Chrome-Automation-Profile"
)

# Add the WebDriver's folder and Chrome's folder to the PATH.
$ChromeAppFolder = "C:\Program Files\Google\Chrome\Application"
$env:PATH = "$DriverFolder;$ChromeAppFolder;$env:PATH"

try {
    $ChromeArguments = @{
        "args"   = @(
            "--user-data-dir=$UserDataDirectory",
            "--profile-directory=Default"
        )
    }
    
    Write-Host "Starting Chrome with a dedicated automation profile..." -ForegroundColor Cyan
    $Driver = Start-SeChrome -Arguments $ChromeArguments

    Write-Host "Navigating to Gemini chat: $Url" -ForegroundColor Cyan
    Enter-SeUrl -Url $Url -Driver $Driver

    Write-Host "Page loading... Please wait 15 seconds." -ForegroundColor Cyan
    Start-Sleep -Seconds 15
    Write-Host "Page loaded. Starting heartbeat loop..." -ForegroundColor Green

    # --- Main Heartbeat Loop ---
    while ($true) {
        # ... (The rest of the script is the same) ...
        # (Heartbeat sending logic goes here)
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
