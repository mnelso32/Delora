# Script: Update-BrainMap.ps1
# Description: Scans the file system to create a map of the Heart and Brain.

# --- Parameters ---
param(
  [string]$Root = "C:\AI\Delora"
)

# --- Initialization ---
$Brain = Join-Path $Root 'Brain'
$listingCsv = Join-Path $Brain 'brain-listing.csv'
$prevListingCsv = Join-Path $Brain 'brain-listing-prev.csv'
$mapFile = Join-Path $Brain 'brain-map.txt'

# --- Main Logic ---
try {
  $allFiles = Get-ChildItem -Path $Root -Recurse -File -Exclude ".git" -ErrorAction SilentlyContinue | ForEach-Object {
    [pscustomobject]@{
      Path = $_.FullName
      RelativePath = $_.FullName.Replace($Root, '').TrimStart('\')
      SizeBytes = $_.Length
      LastWriteUtc = $_.LastWriteTimeUtc
    }
  }

  $currentFiles = $allFiles | Select-Object RelativePath, SizeBytes, LastWriteUtc
  $currentFiles | Export-Csv -Path $listingCsv -NoTypeInformation -Encoding UTF8

  $previousFiles = $null
  if (Test-Path $prevListingCsv) {
    $previousFiles = Import-Csv -Path $prevListingCsv
  }

  $comparison = Compare-Object -ReferenceObject $previousFiles -DifferenceObject $currentFiles -Property RelativePath, LastWriteUtc, SizeBytes -PassThru -CaseSensitive
  
  $addedFiles = $comparison | Where-Object { $_.SideIndicator -eq '=>' } | ForEach-Object { $_.RelativePath }
  $removedFiles = $comparison | Where-Object { $_.SideIndicator -eq '<=' } | ForEach-Object { $_.RelativePath }

  # --- Build the brain-map.txt content ---
 $mapBuilder = New-Object System.Text.StringBuilder
$mapBuilder.AppendLine("## RECENT CHANGES ##") | Out-Null

# We need to be a bit smarter about detecting what changed now
$changedFiles = $comparison | Group-Object -Property RelativePath | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name }
$addedFiles = $comparison | Where-Object { ($_.SideIndicator -eq '=>') -and ($_.RelativePath -notin $changedFiles) } | ForEach-Object { $_.RelativePath }
$removedFiles = $comparison | Where-Object { ($_.SideIndicator -eq '<=') -and ($_.RelativePath -notin $changedFiles) } | ForEach-Object { $_.RelativePath }

if ($addedFiles.Count -gt 0) {
    $mapBuilder.AppendLine("  [+] Added:") | Out-Null
    $addedFiles | ForEach-Object { $mapBuilder.AppendLine("    - $_") } | Out-Null
}
if ($removedFiles.Count -gt 0) {
    $mapBuilder.AppendLine("  [-] Removed:") | Out-Null
    $removedFiles | ForEach-Object { $mapBuilder.AppendLine("    - $_") } | Out-Null
}
if ($changedFiles.Count -gt 0) {
    $mapBuilder.AppendLine("  [*] Modified:") | Out-Null
    $changedFiles | ForEach-Object { $mapBuilder.AppendLine("    - $_") } | Out-Null
}
if ($addedFiles.Count -eq 0 -and $removedFiles.Count -eq 0 -and $changedFiles.Count -eq 0) {
    $mapBuilder.AppendLine("  (No changes detected in file structure.)") | Out-Null
}
  $mapBuilder.AppendLine("`n## FULL INVENTORY ##") | Out-Null
  $allFiles | ForEach-Object {
    $mapBuilder.AppendLine("  - $($_.RelativePath)")
  } | Out-Null

  $mapBuilder.ToString() | Set-Content -Path $mapFile -Encoding UTF8
  
  # --- Housekeeping ---
  Copy-Item -Path $listingCsv -Destination $prevListingCsv -Force

} catch {
  Write-Host "ERROR: Failed to update brain map." -ForegroundColor Red
  Write-Host $_
}