
# Update-DeloraCrowns.ps1 (v2.1 - Corrected for New Architecture)
[CmdletBinding()]
param(
[ValidateSet('Day', 'Week', 'Month')]
[string]$Scope = 'Day',
[string]$Root = "C:\AI\Delora" # CORRECTED: Root is now Delora
)


$ErrorActionPreference = "Stop"
$pinsCsv = Join-Path $Root "Heart\Heart-Memories\pins.csv"
$logicModulePath = Join-Path $Root 'Tools\Modules\Delora.psm1'
Import-Module -Name $logicModulePath -Force

# Main Logic
Write-Host "Updating $Scope crowns..." -ForegroundColor Cyan
if (-not (Test-Path $pinsCsv)) { Write-Warning "pins.csv not found."; return }
$pins = @(Import-Csv $pinsCsv)

# Define Time Window 
$today = Get-Date
$startDate = $today.Date
$endDate = $today.Date.AddDays(1).AddTicks(-1)
if ($Scope -eq 'Week') {
$startOfWeek = $today.Date.AddDays(-[int]$today.DayOfWeek)
$startDate = $startOfWeek
$endDate = $startOfWeek.AddDays(7).AddTicks(-1)
} elseif ($Scope -eq 'Month') {
$startDate = Get-Date -Day 1 -Hour 0 -Minute 0 -Second 0
$endDate = $startDate.AddMonths(1).AddTicks(-1)
}

# Find Winner 
$candidates = $pins | Where-Object {
    $_.type -eq 'event' -and $_.date -and ([datetime]$_.date -ge $startDate) -and ([datetime]$_.date -le $endDate)
}

if ($candidates.Count -eq 0) {
Write-Host "No 'event' pins found for this $Scope to crown. Exiting gracefully."
return
}

$winner = $candidates | Sort-Object @{Expression={ Measure-DeloraPinScore $_ }; Descending=$true} | Select-Object -First 1
$winnerScore = Measure-DeloraPinScore $winner

# Upsert Crown Logic 
crownId="D−CROWN−($Scope.ToUpper())-{0:yyyyMMdd}" -f $startDate
$existingCrown = $pins | Where-Object { $_.id -eq $crownId }

if ($existingCrown) {
$oldWinnerId = if ($existingCrown.tags -match 'winner:([^;]+)') { $Matches[1] } else { '' }
$oldWinner = $pins | Where-Object { $_.id -eq $oldWinnerId }
$oldScore = if ($oldWinner) { Measure-DeloraPinScore $oldWinner } else { -999 }
if ($winnerScore -gt $oldScore) {
Write-Host "New winner found for $Scope crown with a higher score." -ForegroundColor Yellow
existingCrown.tags="crown;crown−(Scope.ToLower());winner:($winner.id)"
$existingCrown.title = "Crown ($Scope): $($winner.title)"
$existingCrown.content = "The most significant event for this Scopewas 
′
 (winner.title) 
′
 (($winner.id)) with a score of $winnerScore."
} else {
Write-Host "Existing crown for $Scope is already optimal. No changes made."
return
}
} else {
$newCrown = [pscustomobject]@{
    id      = $crownId
    priority= 5
    type    = 'crown'
    date    = '{0:yyyy-MM-dd}' -f $today # <-- Added '$' and semicolon
    tags    = "crown;crown-$($Scope.ToLower());winner:$($winner.id)" # <-- Corrected dash
    title   = "Crown ($Scope): $($winner.title)"
    content = "The most significant event for this $Scope was '$($winner.title)' ($($winner.id)) with a score of $winnerScore."
    source  = 'Update-DeloraCrowns.ps1'
}
$pins += $newCrown
}

$pins | Export-Csv -Path $pinsCsv -NoTypeInformation -Encoding UTF8
Write-Host "✔ Successfully updated crown for $Scope." -ForegroundColor Green
