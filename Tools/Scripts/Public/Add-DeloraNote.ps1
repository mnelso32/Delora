# Add-DeloraNote.ps1 (v2.0)
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [string]$Content,
    # New parameter to accept a file path for the content
    [string]$ContentFromFile,
    [string]$Root = "C:\AI\Delora"
)

try {
    if ($PSBoundParameters.ContainsKey('ContentFromFile')) {
        $Content = Get-Content -Path $ContentFromFile -Raw
    }

    $fullPath = Join-Path -Path $Root -ChildPath $Path
    $directory = Split-Path -Path $fullPath
    if (-not (Test-Path -Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    # Use "`n" to ensure the appended content starts on a new line
    Add-Content -Path $fullPath -Value "`n$Content"
    Write-Host "✅ Note successfully appended to: $fullPath" -ForegroundColor Green

} catch {
    Write-Error "Failed to append note. Error: $_"
}