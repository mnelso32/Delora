#requires -Version 7.0
#
# This script's job is to update the local state file to track "turns"
# and the time of the last update.

[CmdletBinding()]
param(
    [string]$Root = "C:\AI\Delora\Heart"
)

# --- Setup ---
$ErrorActionPreference = "SilentlyContinue"
# CORRECTED PATH: Assumes $Root is the Heart directory
$statePath = Join-Path $Root 'Time\Pulse\pulse.json'

# --- Helper Functions ---
function Read-State {
    param([string]$Path)
    if (Test-Path $Path) {
        return Get-Content $Path -Raw | ConvertFrom-Json
    }
    return [pscustomobject]@{ turns = 0; lastRefreshUtc = "" }
}

function Write-State {
    param([string]$Path, [object]$State)
    $dir = Split-Path $Path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $State | ConvertTo-Json -Depth 3 | Set-Content -Path $Path -Encoding UTF8
}

# --- Main Logic ---
$state = Read-State $statePath
$state.turns = [int]$state.turns + 1
$state.lastRefreshUtc = (Get-Date).ToUniversalTime().ToString('o')

Write-State -Path $statePath -State $state

Write-Host "✔ Heartbeat state updated. Turns: $($state.turns)" -ForegroundColor Green
