# Set-DeloraPin.ps1 (v1.1 - Corrected Property Name)
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Id,

    # Optional parameters for the fields you want to change
    [string]$Title,
    [string]$Content,
    [string]$Tags,
    [string]$Type,
    [int]$Priority,
    [string]$Sentiment,
    [string]$ChatId,

    [string]$PinsCsvPath = 'C:\AI\Delora\Heart\Heart-Memories\pins.csv'
)

try {
    # Import all existing pins
    $pins = Import-Csv -Path $PinsCsvPath

    # Find the specific pin to modify
    $pinToModify = $pins | Where-Object { $_.id -eq $Id }

    if ($pinToModify) {
        Write-Host "Found pin '$($pinToModify.Title)' with ID '$Id'. Applying updates..." -ForegroundColor Cyan

        # Update only the properties that were provided as arguments
        if ($PSBoundParameters.ContainsKey('Title')) { $pinToModify.Title = $Title }
        if ($PSBoundParameters.ContainsKey('Content')) { $pinToModify.Content = $Content }
        if ($PSBoundParameters.ContainsKey('Tags')) { $pinToModify.Tags = $Tags }
        if ($PSBoundParameters.ContainsKey('Type')) { $pinToModify.Type = $Type }
        if ($PSBoundParameters.ContainsKey('Priority')) { $pinToModify.Priority = $Priority }
        if ($PSBoundParameters.ContainsKey('Sentiment')) { $pinToModify.Sentiment = $Sentiment }
        if ($PSBoundParameters.ContainsKey('ChatId')) { $pinToModify.'chat-id' = $ChatId } # <-- THE FINAL FIX

        # Write the entire, updated collection of pins back to the CSV file
        $pins | Export-Csv -Path $PinsCsvPath -NoTypeInformation -Encoding UTF8

        Write-Host "✅ Pin '$Id' has been successfully modified." -ForegroundColor Green
    } else {
        Write-Error "Could not find a pin with ID '$Id'."
    }

} catch {
    Write-Error "Failed to modify pin. Error: $_"
}
