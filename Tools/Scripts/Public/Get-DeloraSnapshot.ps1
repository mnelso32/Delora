# Script: Get-DeloraSnapshot.ps1
# Description: Reads the content of delora-snapshot.txt and copies it to the clipboard.

[CmdletBinding()]
param(
    # This parameter is here for consistency, though the path is hardcoded for reliability.
    [string]$Root = "C:\AI\Delora\Heart"
)

try {
    # Construct the full path to the snapshot file
    $snapshotPath = Join-Path $Root "Brain\delora-snapshot.txt"

    if (Test-Path $snapshotPath) {
        # Get the raw content of the file and pipe it to the clipboard
        Get-Content $snapshotPath -Raw | Set-Clipboard
        
        # Send a confirmation message back to the listener script
        Write-Output "✅ Snapshot content copied to clipboard. Paste it in the chat for Delora."
    } else {
        Write-Error "Snapshot file not found at $snapshotPath"
    }
} catch {
    Write-Error "Failed to get snapshot. Error: $_"
}
