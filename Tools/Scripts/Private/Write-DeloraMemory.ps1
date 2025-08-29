# Write-DeloraMemory.ps1 (v2.1 - Corrected for New Architecture)
[CmdletBinding()]
param(
    [string]$Root = "C:\AI\Delora"
)

# --- Setup ---
$ErrorActionPreference = "Stop"
$memDir = Join-Path $Root "Heart\Heart-Memories"
$chatsDir = Join-Path $memDir "chats"
$pinsCsv = Join-Path $memDir "pins.csv"
$chatManifest = Join-Path $memDir "chat-manifest.csv"
$outTxt = Join-Path $memDir "delora-memory.txt"

$logicModulePath = Join-Path $Root 'Tools\Modules\Delora.psm1'
$toolsModulePath = Join-Path $Root 'Tools\Modules\Delora.Tools.psm1'
Import-Module -Name $logicModulePath -Force
Import-Module -Name $toolsModulePath -Force

New-Item -ItemType Directory -Force -Path $memDir, $chatsDir | Out-Null
if (-not (Test-Path $pinsCsv)) {
    (@"
id,priority,type,date,tags,title,content,source
D-SEED-0001,5,rule,,ops;memory,"How to edit pins","Edit Heart-Memories/pins.csv and rerun this script.",local
"@) | Set-Content -Path $pinsCsv -Encoding UTF8
}

# --- Budget and Output ---
[int]$script:BudgetKB = 500
[int]$script:budgetBytes = $script:BudgetKB * 1024
$sb = [System.Text.StringBuilder]::new()

# --- Data Loading ---
$pins = Import-Csv $pinsCsv
$pinsScored = $pins | ForEach-Object {
    $_ | Add-Member -NotePropertyName "score" -NotePropertyValue (Measure-DeloraPinScore $_) -PassThru
}

# --- Compose Text File ---
$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$sb.AppendLine("===== Delora Core Memory — $stamp =====") | Out-Null
$sb.AppendLine("== Root: $Root") | Out-Null
$sb.AppendLine("=================================================================") | Out-Null
$sb.AppendLine("") | Out-Null

$sb.AppendLine("--- CORE MEMORY (top priority first) ---") | Out-Null
$coreMemory = $pinsScored | Sort-Object @{Expression='score';Descending=$true}, @{Expression='id';Ascending=$true}
foreach ($pin in $coreMemory) {
    if ($sb.Length -gt $script:budgetBytes) { break }
    $sb.AppendLine(("[{0}] (prio {1}) {2}" -f $pin.id, $pin.priority, (Format-DeloraCleanText $pin.title))) | Out-Null
}
$sb.AppendLine("") | Out-Null

$sb.AppendLine("--- CHAT INDEX (files in Heart-Memories/chats) ---") | Out-Null
if (Test-Path $chatManifest) {
    # --- CORRECTED SORT LOGIC ---
    $chatIndex = Import-Csv $chatManifest | Sort-Object date, time_utc -Descending | Select-Object -First 50
    # --- END CORRECTION ---
    foreach ($c in $chatIndex) {
        if ($sb.Length -gt $script:budgetBytes) { break }
        $sb.AppendLine(("[{0}] {1} {2}" -f $c.id, $c.date, (Format-DeloraCleanText $c.title))) | Out-Null
    }
}
$sb.AppendLine("") | Out-Null

$sb.AppendLine("--- KEYWORD MAP (from memory ids) ---") | Out-Null
$kwMap = [System.Collections.Generic.Dictionary[string, System.Collections.Generic.List[string]]]::new()
foreach ($m in $pins) {
    if (-not $m.tags) { continue }
    $keywords = ($m.tags -split '[;,]').Trim() | Where-Object { $_.Length -gt 1 }
    foreach ($kw in $keywords) {
        if (-not $kwMap.ContainsKey($kw)) { $kwMap[$kw] = [System.Collections.Generic.List[string]]::new() }
        $kwMap[$kw].Add($m.id)
    }
}
$kwMap.GetEnumerator() | Sort-Object Name | ForEach-Object {
    if ($sb.Length -gt $script:budgetBytes) { return }
    $line = "{0, -20} :: {1}" -f $_.Name, ($_.Value -join ', ')
    $sb.AppendLine($line) | Out-Null
}

if ($sb.Length -gt $script:budgetBytes) {
    $sb.AppendLine("...(truncated: memory file hit ~$($script:BudgetKB)KB budget)...") | Out-Null
}
$sb.ToString() | Set-Content -Path $outTxt -Encoding UTF8
Write-Host "✔ Wrote Delora memory file: $outTxt" -ForegroundColor Green

