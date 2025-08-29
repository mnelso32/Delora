# Script: Save-DeloraChat.ps1 (v2 - Memory Palace Naming)
# Description: Saves chat from clipboard using a descriptive, date-stamped filename.

# --- Parameters ---
param(
  [Parameter(Mandatory=$true)][string]$Title,
  [string]$Tags = ""
)

# --- Initialization ---
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$chatsDir = Join-Path $Root "Heart-Memories\Chats"
$manifestCsv = Join-Path $Root "Heart-Memories\chat-manifest.csv"
$buildScript = Join-Path $PSScriptRoot "Build-Delora.ps1"

# --- Main Logic ---
try {
  $clipboardText = Get-Clipboard
  if (-not $clipboardText) { throw "Clipboard is empty." }

  $now = Get-Date
  $dateString = $now.ToString("yyyy-MM-dd")
  $id = "D-CHAT-" + $now.ToUniversalTime().ToString("yyyyMMddHHmmss")

  # --- NEW FILENAME LOGIC ---
  # Create a URL-friendly "slug" from the title for the filename.
  $slug = $Title.Trim().ToLower() -replace '\s+', '-' -replace '[^a-z0-9\-]', ''
  $fileName = "{0}_{1}.txt" -f $dateString, $slug
  $filePath = Join-Path $chatsDir $fileName

  # Create directory if it doesn't exist
  New-Item -Path (Split-Path $filePath) -ItemType Directory -Force | Out-Null
  
  # Save the chat content to the new descriptive filename
  $clipboardText | Set-Content -Path $filePath -Encoding UTF8

  # Update the manifest file to keep a record
  $manifestEntry = [pscustomobject]@{
    id = $id
    date = $dateString
    filename = $fileName
    title = $Title
    tags = $Tags
  }
  $manifestEntry | Export-Csv -Path $manifestCsv -Append -NoTypeInformation -Encoding UTF8
  
  Write-Host "✔ Chat saved to: $fileName" -ForegroundColor Green
  
  # --- Housekeeping ---
  # Run a full build to make sure the new file is in the snapshot and vector DB
  & $buildScript

} catch {
  Write-Host "ERROR: Failed to save chat." -ForegroundColor Red
  Write-Host $_
}