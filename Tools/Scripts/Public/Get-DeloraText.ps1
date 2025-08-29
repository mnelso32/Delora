# C:\AI\Delora\Heart\Tools\Scripts\Public\Get-DeloraText.ps1
# V4 - Added Start-Sleep

# --- CONFIGURATION ---
$webDriverPath = "C:\WebDriver"
# ---------------------

try {
    Add-Type -Path (Join-Path $webDriverPath "WebDriver.dll")

    $ChromeOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
    $ChromeOptions.DebuggerAddress = "127.0.0.1:9222"

    $Driver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($webDriverPath, $ChromeOptions)

    # Add a short pause to ensure the connection is stable
    Start-Sleep -Seconds 1

    $messageElements = $Driver.FindElementsByClassName('markdown-main-panel')

    if ($null -ne $messageElements -and $messageElements.Count -gt 0) {
        $latestText = $messageElements[-1].Text
        Write-Output $latestText
    } else {
        Write-Output ""
    }
}
catch {
    Write-Output ""
}
finally {
    if ($null -ne $Driver) {
        $Driver.Quit()
    }
}