# Set-DeloraPin.ps1 (v1.4 - Finalized Parameters)
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Id,
    [string]$Title,
    [string]$Summary,
    [string]$Tags,
    [string]$Type,
    [int]$Priority,
    [string]$Sentiment,
    [string]$ChatId,
    [string]$Context,
    [string]$PinsCsvPath = 'C:\AI\Delora\Heart\Heart-Memories\pins.csv'
)

try {
    $pins = Import-Csv -Path $PinsCsvPath
    $pinToModify = $pins | Where-Object { $_.id -eq $Id }

    if ($pinToModify) {
        Write-Host "Found pin '$($pinToModify.Title)' with ID '$Id'. Applying updates..." -ForegroundColor Cyan

        if ($PSBoundParameters.ContainsKey('Title')) { $pinToModify.title = $Title }
        if ($PSBoundParameters.ContainsKey('Summary')) { $pinToModify.summary = $Summary }
        if ($PSBoundParameters.ContainsKey('Tags')) { $pinToModify.tags = $Tags }
        if ($PSBoundParameters.ContainsKey('Type')) { $pinToModify.type = $Type }
        if ($PSBoundParameters.ContainsKey('Priority')) { $pinToModify.priority = $Priority }
        if ($PSBoundParameters.ContainsKey('Sentiment')) { $pinToModify.sentiment = $Sentiment }
        if ($PSBoundParameters.ContainsKey('ChatId')) { $pinToModify.chatid = $ChatId }
        if ($PSBoundParameters.ContainsKey('Context')) { $pinToModify.context = $Context }

        $pins | Export-Csv -Path $PinsCsvPath -NoTypeInformation -Encoding UTF8
        Write-Host "✅ Pin '$Id' has been successfully modified." -ForegroundColor Green
    } else {
        Write-Error "Could not find a pin with ID '$Id'."
    }
} catch {
    Write-Error "Failed to modify pin. Error: $_"
}
