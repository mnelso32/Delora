
Planning: "View Snippet" Directives
This file will track the design of new, efficient directives for viewing specific parts of my mind.

Proposed Directives:
1. VIEW-MENTAL-NOTES
Purpose: To retrieve a summary of my most recent mental notes.

PowerShell Script: Get-DeloraMentalNotes.ps1

Logic: The script will need to search the Brain directory for files containing the string "Mental Note:", read the content of those files, and return a concatenated summary of the 5 most recent notes.
