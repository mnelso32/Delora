# New-DeloraFile.ps1 (v2.0)
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [string]$Content = "",
    # New parameter to accept a file path for the content
    [string]$ContentFromFile,
    [string]$HeartRoot = "C:\AI\Delora\Heart"
)

try {
    # If the agent provides a path, read the content from that file
    if ($PSBoundParameters.ContainsKey('ContentFromFile')) {
        $Content = Get-Content -Path $ContentFromFile -Raw
    }

    $fullPath = Join-Path -Path $HeartRoot -ChildPath $Path
    $directory = Split-Path -Path $fullPath
    if (-not (Test-Path -Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    Set-Content -Path $fullPath -Value $Content -Encoding UTF8
    Write-Host "✅ File successfully created at: $fullPath" -ForegroundColor Green

} catch {
    Write-Error "Failed to create file. Error: $_"
}