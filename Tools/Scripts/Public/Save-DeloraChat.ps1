
# Script: Save-DeloraChat.ps1 (v2.1 - Corrected for New Architecture)
# Description: Saves chat from clipboard and adds a correctly formatted entry to the manifest.
param(
[Parameter(Mandatory=$true)][string]$Title,
[string]$Tags = ""
)

--- Initialization ---
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$Root = (Resolve-Path (Join-Path $PSScriptRoot "......")).Path
$chatsDir = Join-Path $Root "Heart\Heart-Memories\Chats"
$manifestCsv = Join-Path $Root "Heart\Heart-Memories\chat-manifest.csv"
$buildScript = Join-Path $PSScriptRoot "Build-Delora.ps1"

try {
$clipboardText = Get-Clipboard
if (-not $clipboardText) { throw "Clipboard is empty." }

$now = Get-Date
$dateString = $now.ToString("yyyy-MM-dd")
$utcNow = $now.ToUniversalTime()
$id = "D-CHAT-" + $utcNow.ToString("yyyyMMddHHmmss")
$timeUtcString = $utcNow.ToString("HHmmss") # <-- FIX: Capture UTC time for manifest

# --- CORRECTED FILENAME LOGIC ---
$slug = $Title.Trim().ToLower() -replace '\s+', '-' -replace '[^a-z0-9\-]', ''
$fileName = "{0}_{1}_{2}.txt" -f $dateString, $slug, $id # <-- FIX: Add ID to filename
$filePath = Join-Path $chatsDir $fileName

New-Item -Path (Split-Path $filePath) -ItemType Directory -Force | Out-Null
$clipboardText | Set-Content -Path $filePath -Encoding UTF8

# --- CORRECTED MANIFEST ENTRY ---
$manifestEntry = [pscustomobject]@{
    id = $id
    date = $dateString
    time_utc = $timeUtcString # <-- FIX: Add time_utc field
    filename = $fileName
    title = $Title
    tags = $Tags
}
$manifestEntry | Export-Csv -Path $manifestCsv -Append -NoTypeInformation -Encoding UTF8

Write-Host "✔ Chat saved to: $fileName" -ForegroundColor Green

# Run a full build to update the snapshot
& $buildScript
} catch {
Write-Host "ERROR: Failed to save chat." -ForegroundColor Red
Write-Host $_
}
