#requires -Version 7.0
# This script runs a continuous loop to build the latest context and send it as a
# heartbeat prompt to the Google Gemini cloud-based LLM.

[CmdletBinding()]
param(
    # The root directory of the AI persona to run (e.g., C:\AI\Delora\Heart)
    [string]$AiRoot = "C:\AI\Delora\Heart",
    # Your secret API key for the Google AI service
    [string]$ApiKey = "AIzaSyCEeHxjUwbous4UKyhrZ2lRkikMfWIv4qE",
    # The model name to use for the API call
    [string]$Model = "gemini-1.5-pro-latest",
    [int]$IntervalSeconds = 300
)

# --- Setup ---
$ErrorActionPreference = 'Stop'
# --- CORRECTED: The API endpoint for Google Gemini ---
$ApiUri = "https://generativelanguage.googleapis.com/v1beta/models/$($Model):generateContent?key=$($ApiKey)"
# ---

$buildScriptPath = Join-Path $AiRoot "Tools\Scripts\Build-Delora.ps1"
$heartbeatsFile = Join-Path $AiRoot "heartbeats.txt"
$brainFile = Join-Path $AiRoot "Brain\brain.txt"

Write-Host "Starting CLOUD heartbeat loop for $AiRoot. Pulse interval: $IntervalSeconds seconds." -ForegroundColor Magenta

# --- Main Loop ---
while ($true) {
    Write-Host "`n($(Get-Date)) - Starting new cloud heartbeat cycle..." -ForegroundColor Yellow
    
    # 1. Build the latest context files for the target AI
    & $buildScriptPath -Root $AiRoot
    
    # 2. Prepare the full prompt
    $heartbeatInstructions = Get-Content $heartbeatsFile -Raw
    $brainState = Get-Content $brainFile -Raw
    # For Gemini, the core instructions work best as the first part of the user's message
    $fullPrompt = @"
$heartbeatInstructions

--- CURRENT BRAIN STATE ---

$brainState
"@
    
    # --- CORRECTED: The request body format for Google Gemini ---
    $headers = @{ "Content-Type" = "application/json" }
    $body = @{
        contents = @(
            @{
                parts = @(
                    @{
                        text = $fullPrompt
                    }
                )
            }
        )
    } | ConvertTo-Json -Depth 5
    # ---

    try {
        $response = Invoke-RestMethod -Uri $ApiUri -Method Post -Headers $headers -Body $body
        # --- CORRECTED: The response format for Google Gemini ---
        $aiResponse = $response.candidates[0].content.parts[0].text
        # ---
        Write-Host "--- Cloud AI Response ---" -ForegroundColor Magenta
        Write-Host $aiResponse
        Write-Host "-----------------------" -ForegroundColor Magenta
    }
    catch {
        Write-Warning "Failed to send prompt to Cloud LLM."
        Write-Warning $_.Exception.Message
    }
    
    # 4. Wait for the next cycle
    Write-Host "Cycle complete. Waiting for $IntervalSeconds seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds $IntervalSeconds
}