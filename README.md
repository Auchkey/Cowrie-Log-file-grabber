# Cowrie TTY Log Parser Script


Bash script that parses cowrie's specific TTY log files using the provided playlog.py file, with regex to match any patterns contained within. Any files containing a match may be moved or copied to another folder.


**Syntax:**

copyfiles [-v] [{-c|-v} Foldername] ["Pattern"]


**Options:**

-v | --verbose # Output files containing match to console (verbose mode).

-m | --move    # Specify where to move matched files (cannot be used with -c | --move).

-c | --copy    # Specify where to copy matched files (cannot be used with -m | --move).


**Usage examples:**

The following example scans files containing 'Clare' or 'Claire' and moves them to 'myFolder':

`copyfiles -m myFolder "Clai?re"`

This will just output the names of files containing part of a ping sequence:

`copyfiles -v "icmp_seq=[0-9]{,3} ttl=[0-9]{,3}"`

