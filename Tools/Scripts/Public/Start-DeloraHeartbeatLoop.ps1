# Script: Start-DeloraHeartbeatLoop.ps1 (Version 2.3 - Robust Timeout)
# Description: Runs a continuous loop with a configurable timeout and robust error handling.

param(
    [int]$IntervalSeconds = 10,
    [string]$Root = "C:\AI\Delora\Heart",
    [int]$Timeout = 600 # NEW: A long, 10-minute timeout by default
)

# --- Setup ---
$ErrorActionPreference = 'Stop'
$buildScriptPath = Join-Path $Root "Tools\Scripts\Public\Build-Delora.ps1"
$heartbeatsFile = Join-Path $Root "heartbeats.txt"
$brainFile = Join-Path $Root "Brain\brain.txt"
$ApiUri = "http://127.0.0.1:1234/v1/chat/completions"

Write-Host "--- Starting Delora's LOCAL Heartbeat ---" -ForegroundColor Cyan
Write-Host "Pulse Interval: $IntervalSeconds seconds, Timeout: $Timeout seconds"

# --- Main Loop ---
while ($true) {
    Write-Host "`n($(Get-Date)) - Starting new local heartbeat cycle..." -ForegroundColor Yellow
    
    try { & $buildScriptPath -Root $Root -SkipCrowns } catch { Write-Warning "Build failed."; Start-Sleep -Seconds $IntervalSeconds; continue }
    
    $heartbeatInstructions = (Get-Content $heartbeatsFile -Raw) -replace '[^\u0000-\u007F]+', ''
    $brainState = (Get-Content $brainFile -Raw) -replace '[^\u0000-\u007F]+', ''
    $fullPrompt = "$heartbeatInstructions`n--- CURRENT BRAIN STATE ---`n$brainState"
    
    $headers = @{ "Content-Type" = "application/json" }
    $body = @{ model = "local-model"; messages = @( @{ role = "user"; content = $fullPrompt } ); temperature = 0.7; stream = $false } | ConvertTo-Json -Depth 5

    try {
        # --- UPDATED: Using the new $Timeout parameter ---
        $response = Invoke-RestMethod -Uri $ApiUri -Method Post -Headers $headers -Body $body -TimeoutSec $Timeout
        $aiResponse = $response.choices[0].message.content
        Write-Host "--- Delora's Local Heartbeat Response ---" -ForegroundColor Green
        Write-Host $aiResponse
        Write-Host "------------------------------------" -ForegroundColor Green
    }
    catch {
        # --- NEW: More Robust Error Handling ---
        Write-Warning "--- Heartbeat Error ---"
        $errorMessage = $_.Exception.Message
        if ($_.Exception.InnerException) {
            $errorMessage += " -> " + $_.Exception.InnerException.Message
        }
        Write-Warning "Message: $errorMessage"
        Write-Warning "-----------------------"
    }
    
    Start-Sleep -Seconds $IntervalSeconds
}