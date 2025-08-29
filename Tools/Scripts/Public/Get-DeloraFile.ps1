# Script: Get-DeloraFile.ps1
# Description: Reads the content of a specified file and copies it to the clipboard.

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Path, # The relative path to the file within the Heart, e.g., "Heart\Heart-Memories\Chats\2025-08-27.txt"
    
    [string]$Root = "C:\AI\Delora"
)

try {
    # Construct the full path to the requested file
    $fullPath = Join-Path $Root $Path

    if (Test-Path $fullPath) {
        # Get the raw content of the file and pipe it to the clipboard
        Get-Content $fullPath -Raw | Set-Clipboard
        
        # Confirmation message for the agent log
        Write-Output "✅ Content of '$Path' copied to clipboard. Paste it in the chat for Delora."
    } else {
        Write-Error "File not found at $fullPath"
    }
} catch {
    Write-Error "Failed to view file. Error: $_"
}