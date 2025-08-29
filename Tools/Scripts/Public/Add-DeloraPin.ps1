# Add-DeloraPin.ps1 (v2.0 - Temp File Support)
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Title,
    [string]$Content,
    # New parameter to accept a file path for the content
    [string]$ContentFromFile,
    [string]$Tags = "",
    [string]$Type = "note",
    [int]$Priority = 3,
    [string]$Source = "local",
    [string]$Sentiment = "",
	[string]$ChatId = ""
)

# --- Initialization ---
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$pinsCsv = Join-Path $Root "Heart\Heart-Memories\pins.csv"

try {
    # If the agent provides a path, read the content from that file
    if ($PSBoundParameters.ContainsKey('ContentFromFile')) {
        $Content = Get-Content -Path $ContentFromFile -Raw
    }

    $utcDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd")
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyyMMddHHmmss")
    $id = "D-PIN-$timestamp"

    $newPin = [pscustomobject]@{
        id = $id
        priority = $Priority
        type = $Type
        date = $utcDate
        tags = $Tags
        title = $Title
        content = $Content
        source = $Source
        sentiment = $Sentiment
		chat-id = $ChatId
    }

    # Import existing pins, add the new one, and export back to the file
    $allPins = @(Import-Csv -Path $pinsCsv)
    $allPins += $newPin
    $allPins | Export-Csv -Path $pinsCsv -NoTypeInformation -Encoding UTF8

    Write-Host "✅ Pin '$Title' has been successfully added with ID '$id'." -ForegroundColor Green

} catch {
    Write-Error "Failed to add pin. Error: $_"
}


