# Get-DeloraMentalNotes.ps1
# Description: Finds the 5 most recent "Mental Note" entries in the Brain and copies them to the clipboard.
[CmdletBinding()]
param(
    [string]$BrainRoot = 'C:\AI\Delora\Heart\Brain',
    [int]$NoteCount = 5
)

try {
    # Find all files in the Brain, recursively
    $allFiles = Get-ChildItem -Path $BrainRoot -Recurse -File

    $allNotes = foreach ($file in $allFiles) {
        # Read the content of each file and find lines containing "Mental Note:"
        Get-Content -Path $file.FullName | Select-String -Pattern "Mental Note:" | ForEach-Object {
            # Create a custom object for each note with its content and the file's last write time
            [pscustomobject]@{
                NoteContent = $_.Line
                Timestamp = $file.LastWriteTime
            }
        }
    }

    if ($allNotes) {
        # Sort the notes by their timestamp in descending order (newest first) and take the top N
        $recentNotes = $allNotes | Sort-Object Timestamp -Descending | Select-Object -First $NoteCount

        $noteSummary = "--- RECENT MENTAL NOTES ---\n\n"
        $recentNotes | ForEach-Object {
            $noteSummary += "$($_.NoteContent)\n\n"
        }

        # Copy the final summary to the clipboard
        $noteSummary | Set-Clipboard
        
        Write-Host "✅ Successfully copied the $($recentNotes.Count) most recent mental notes to the clipboard." -ForegroundColor Green
    } else {
        Write-Host "No mental notes found in the Brain." -ForegroundColor Yellow
    }

} catch {
    Write-Error "Failed to get mental notes. Error: $_"
}
