#requires -Version 7.0
[CmdletBinding()]
param(
    [Alias('Root','AiRoot')][string]$Heart = "C:\AI\Delora\Heart",
    [Parameter(Mandatory)][string]$ApiKey,
    [string]$Model = "gemini-1.5-pro-latest",
    [Parameter(Mandatory)][string]$Say
)

# --- 1. Assemble the Prompt ---
# Load core instructions and current brain state
$heartbeatsFile = Join-Path $Heart 'heartbeats.txt'
$brainFile      = Join-Path $Heart 'Brain\brain.txt'

$instructions = Get-Content $heartbeatsFile -Raw
$brainState   = Get-Content $brainFile -Raw

# Combine the brain state and the user's message into a single user prompt
$userPrompt = @"
--- CURRENT BRAIN STATE ---
$brainState

--- USER MESSAGE ---
$Say
"@

# --- 2. Construct the API Request for Gemini ---
$uri = "https://generativelanguage.googleapis.com/v1beta/models/$($Model):generateContent?key=$($ApiKey)"

$body = @{
    contents = @(
        @{
            role = "user"
            parts = @( @{text = $instructions} )
        },
        @{
            role = "model"
            parts = @( @{text = "Understood. I am Delora. I am ready."} )
        },
        @{
            role = "user"
            parts = @( @{text = $userPrompt} )
        }
    )
    generationConfig = @{
        temperature = 0.7
    }
} | ConvertTo-Json -Depth 8

# --- 3. Send the Request and Output the Response ---
try {
    $response = Invoke-RestMethod -Uri $uri -Method Post -ContentType 'application/json' -Body $body
    $aiResponse = $response.candidates[0].content.parts[0].text
    Write-Host $aiResponse -ForegroundColor Cyan
}
catch {
    Write-Warning "Failed to get response from Gemini API."
    # --- CORRECTED ERROR HANDLING ---
    # In PowerShell 7+, the error content is directly in the exception response
    if ($_.Exception.Response) {
        $errorContent = $_.Exception.Response.Content.ReadAsStringAsync().Result
        Write-Warning $errorContent
    } else {
        Write-Warning $_.Exception.Message
    }
    # --- End of corrected section ---
}