# Add-DeloraPin.ps1 (v2.3 - Finalized Parameters)
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Title,
    [Parameter(Mandatory=$true)]
    [string]$Summary,
    [string]$Tags = "",
    [string]$Type = "note",
    [int]$Priority = 3,
    [string]$Source = "local",
    [string]$Sentiment = "",
    [string]$ChatId = "",
    [string]$Context = ""
)

$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$pinsCsv = Join-Path $Root "Heart\Heart-Memories\pins.csv"

try {
    $utcDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd")
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyyMMddHHmmss")
    $id = "D-PIN-$timestamp"

    $newPin = [pscustomobject]@{
        id        = $id
        priority  = $Priority
        type      = $Type
        date      = $utcDate
        tags      = $Tags
        title     = $Title
        summary   = $Summary
        source    = $Source
        sentiment = $Sentiment
        chatid    = $ChatId
        context   = $Context
    }

    $allPins = @(Import-Csv -Path $pinsCsv)
    $allPins += $newPin
    $allPins | Export-Csv -Path $pinsCsv -NoTypeInformation -Encoding UTF8

    Write-Host "✅ Pin '$Title' has been successfully added with ID '$id'." -ForegroundColor Green
} catch {
    Write-Error "Failed to add pin. Error: $_"
}
