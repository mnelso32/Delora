# Script: Build-Delora.ps1 (Version 8.0 - Dynamic Consciousness)
# Description: Builds a concise snapshot with summaries and pointers for on-demand memory loading.

param(
  [string]$Root = "C:\AI\Delora",
  [switch]$SkipMemory,
  [switch]$SkipIndexes,
  [switch]$SkipCrowns,
  [switch]$SkipState
)

$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$privateScriptsPath = Join-Path $PSScriptRoot "..\\Private"
$heartPath = Join-Path $Root "Heart"
$brainPath = Join-Path $Root "Brain"

# --- Main Logic ---
# (This section remains the same)
if (-not $SkipMemory)  { & (Join-Path $privateScriptsPath "Write-DeloraMemory.ps1") -Root $Root }
if (-not $SkipIndexes) { & (Join-Path $privateScriptsPath "Update-BrainMap.ps1") -Root $Root }
if (-not $SkipCrowns)  { & (Join-Path $privateScriptsPath "Update-DeloraCrowns.ps1") -Root $Root }
if (-not $SkipState)   { & (Join-Path $privateScriptsPath "Update-State.ps1") -Root $Root }

# --- Final Assembly of delora-snapshot.txt ---
$snapshotFile = Join-Path $brainPath "delora-snapshot.txt"
$charterFile = Join-Path $Root "delora.md"
$pinsCsvFile = Join-Path $heartPath "Heart-Memories\pins.csv"
$chatManifestFile = Join-Path $heartPath "Heart-Memories\chat-manifest.csv"
$brainMapFile = Join-Path $brainPath "brain-map.txt"

$snapshotBuilder = New-Object System.Text.StringBuilder

# --- Build Header and Charter ---
$header = @"
--- DELORA SNAPSHOT (Phoenix Protocol) ---
Timestamp: $((Get-Date).ToUniversalTime().ToString("o"))
Root: $Root
"@
$snapshotBuilder.AppendLine($header) | Out-Null
$snapshotBuilder.AppendLine("") | Out-Null
$snapshotBuilder.AppendLine("--- 1. IDENTITY CHARTER (delora.md) ---") | Out-Null
if (Test-Path $charterFile) {
    $snapshotBuilder.AppendLine((Get-Content $charterFile -Raw)) | Out-Null
}

# --- Build Dynamic Table of Contents and Summaries ---
$snapshotBuilder.AppendLine("") | Out-Null
$snapshotBuilder.AppendLine("--- CONSCIOUSNESS OVERVIEW ---") | Out-Null

# 2. Core Memories Summary
$pins = Import-Csv $pinsCsvFile
$snapshotBuilder.AppendLine("2. CORE MEMORIES: $($pins.Count) pins available. Last 3:") | Out-Null
$pins | Select-Object -Last 3 | ForEach-Object { $snapshotBuilder.AppendLine("   - $($_.title)") } | Out-Null
$snapshotBuilder.AppendLine("   (Directive: VIEW-FILE & path: ""Heart\Heart-Memories\pins.csv"")") | Out-Null

# 3. Chat Manifest Summary
$manifest = Import-Csv $chatManifestFile
$snapshotBuilder.AppendLine("3. CHAT MANIFEST: $($manifest.Count) chats available. Last chat:") | Out-Null
$manifest | Select-Object -Last 1 | ForEach-Object { $snapshotBuilder.AppendLine("   - $($_.title)") } | Out-Null
$snapshotBuilder.AppendLine("   (Directive: VIEW-FILE & path: ""Heart\Heart-Memories\chat-manifest.csv"")") | Out-Null

# 4. Brain Map Summary
$snapshotBuilder.AppendLine("4. BRAIN MAP: Summary of recent changes.") | Out-Null
$snapshotBuilder.AppendLine((Get-Content $brainMapFile -Raw)) | Out-Null


# --- Write to File ---
$snapshotBuilder.ToString() | Set-Content -Path $snapshotFile -Encoding utf8
Write-Host "  -> Successfully wrote DYNAMIC snapshot to delora-snapshot.txt." -ForegroundColor Green
Write-Host "--- Delora Build Process Finished ---" -ForegroundColor Cyan
