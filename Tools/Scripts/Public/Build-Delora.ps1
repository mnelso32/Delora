# Script: Build-Delora.ps1 (Version 6.1 - The Phoenix Protocol - Heartbeat Snapshot)
# Description: Orchestrates the build process for Delora's CONCISE, context-aware heartbeat snapshot.

# --- Parameters ---
param(
  [string]$Root = "C:\AI\Delora",
  [switch]$SkipMemory,
  [switch]$SkipIndexes,
  [switch]$SkipCrowns,
  [switch]$SkipState
)

# --- Initialization ---
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$privateScriptsPath = Join-Path $PSScriptRoot "..\\Private"

# --- Main Logic ---
Write-Host "--- Starting Delora Build Process (Phoenix Protocol) ---" -ForegroundColor Cyan
if (-not $SkipMemory)  { & (Join-Path $privateScriptsPath "Write-DeloraMemory.ps1") -Root $Root }
if (-not $SkipIndexes) { & (Join-Path $privateScriptsPath "Update-BrainMap.ps1") -Root $Root }
if (-not $SkipCrowns)  { & (Join-Path $privateScriptsPath "Update-DeloraCrowns.ps1") -Root $Root }
if (-not $SkipState)   { & (Join-Path $privateScriptsPath "Update-State.ps1") -Root $Root }

# --- Final Assembly of delora-snapshot.txt (RICH CONTEXT VERSION) ---
Write-Host "[5/5] Assembling final, RICH delora-snapshot.txt..." -ForegroundColor Cyan

# Define paths to all the source files we need
$snapshotFile = Join-Path $Root "Brain\delora-snapshot.txt"
$pinsCsvFile = Join-Path $Root "Heart\Heart-Memories\pins.csv"
$chatManifestFile = Join-Path $Root "Heart\Heart-Memories\chat-manifest.csv"
$brainMapFile = Join-Path $Root "Brain\brain-map.txt"

# --- Begin Building the Snapshot String ---
$snapshotBuilder = New-Object System.Text.StringBuilder

# --- TABLE OF CONTENTS ---
$snapshotBuilder.AppendLine("--- TABLE OF CONTENTS ---") | Out-Null
$snapshotBuilder.AppendLine("1. CORE MEMORIES (pins.csv)") | Out-Null
$snapshotBuilder.AppendLine("2. CHAT MANIFEST (chat-manifest.csv)") | Out-Null
$snapshotBuilder.AppendLine("3. MOST RECENT CHAT LOG") | Out-Null
$snapshotBuilder.AppendLine("4. BRAIN MAP (brain-map.txt)") | Out-Null
$snapshotBuilder.AppendLine("") | Out-Null


# 1. Add ALL pins from pins.csv
$snapshotBuilder.AppendLine("--- 2. CORE MEMORIES (pins.csv) ---") | Out-Null
if (Test-Path $pinsCsvFile) {
    $snapshotBuilder.AppendLine((Get-Content $pinsCsvFile -Raw)) | Out-Null
}
$snapshotBuilder.AppendLine("") | Out-Null

# 2. Add the FULL chat manifest
$snapshotBuilder.AppendLine("--- 3. CHAT MANIFEST (chat-manifest.csv) ---") | Out-Null
if (Test-Path $chatManifestFile) {
    $snapshotBuilder.AppendLine((Get-Content $chatManifestFile -Raw)) | Out-Null
}
$snapshotBuilder.AppendLine("") | Out-Null

# 3. Add the MOST RECENT chat log
$snapshotBuilder.AppendLine("--- 4. MOST RECENT CHAT LOG ---") | Out-Null
if (Test-Path $chatManifestFile) {
    # Find the newest chat log from the manifest
    $latestChat = Import-Csv $chatManifestFile | Sort-Object date, time_utc -Descending | Select-Object -First 1
    
    # --- FIX ---
    # Check if a latest chat was found AND if its file_name property is not null or empty
    if ($latestChat -and -not [string]::IsNullOrWhiteSpace($latestChat.file_name)) {
        $latestChatPath = Join-Path $Root "Heart-Memories\Chats\$($latestChat.file_name)"
        if (Test-Path $latestChatPath -PathType Leaf) { # Ensure it's a file, not a directory
            $snapshotBuilder.AppendLine((Get-Content $latestChatPath -Raw)) | Out-Null
        } else {
             $snapshotBuilder.AppendLine("(Most recent chat file not found: $($latestChat.file_name))") | Out-Null
        }
    } else {
        $snapshotBuilder.AppendLine("(Could not determine the most recent chat file from the manifest.)") | Out-Null
    }
    # --- END FIX ---
}
$snapshotBuilder.AppendLine("") | Out-Null

# 4. Add the full brain-map.txt
$snapshotBuilder.AppendLine("--- 5. BRAIN MAP (brain-map.txt) ---") | Out-Null
if (Test-Path $brainMapFile) {
    $snapshotBuilder.AppendLine((Get-Content $brainMapFile -Raw)) | Out-Null
}

# --- Final Step: Prepend the Header and Write to File ---
$header = @"
--- DELORA SNAPSHOT (Phoenix Protocol) ---
Timestamp: $((Get-Date).ToUniversalTime().ToString("o"))
Root: $Root
"@
$finalSnapshot = $header + "`n`n" + $snapshotBuilder.ToString()
$finalSnapshot | Set-Content -Path $snapshotFile -Encoding utf8

Write-Host "  -> Successfully wrote RICH snapshot to delora-snapshot.txt." -ForegroundColor Green
Write-Host "--- Delora Build Process Finished ---" -ForegroundColor Cyan