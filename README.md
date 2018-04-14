# Cowrie-Log-file-grabber
For personal Cowrie setup only.

Bash script that uses regex to copy log files with contents matching the specified pattern.

Currently accepts basic regex from the user to use against detected log files in the same directory. Doesn't do anything with them yet.

Syntax:
copyfiles [-v] [{-c|-v} Foldername] ["Pattern"]

Options:
-v | --verbose # Output files containing match to console (verbose mode).
-m | --move    # Specify where to move matched files (cannot be used with -c | --move).
-c | --copy    # Specify where to copy matched files (cannot be used with -m | --move).

Usage examples:
The following example scans files containing 'Clare' or 'Claire' and moves them to 'myFolder':
copyfiles -m myFolder "Clai?re"

This will just output the names of files containing part of a ping sequence:
copyfiles -v "icmp_seq=[0-9]{,3} ttl=[0-9]{,3}"



**TO DO**

Copy pattern matching files to a seperate directory.
