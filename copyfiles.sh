#!/bin/bash
# UP819474
#
# Lists, copies or moves cowrie's tty log files which contents match a given regex input.
# See 'usage' function for more information.
#
# The purpose of running the playlog python program is that because cowrie's tty
# log files cannot normally be parsed otherwise (i.e. using cat, grep etc.)
#
# May extend usage to other files in the future.


# Initialisation of default options/flags
verbose="false"
moveFlag="false"
copyFlag="false"


# Displays help and then exits
function usage {
  echo ""
  echo "Syntax:"
  echo "copyfiles.sh [-v] [{-c|-v} Foldername] [\"Pattern\"]"
  echo ""
  echo "Options:"
  echo "-v # Output files containing match to console (verbose mode)."
  echo "-m # Specify where to move matched files (cannot be used with -c)."
  echo "-c # Specify where to copy matched files (cannot be used with -m)."
  echo ""
  echo "Usage examples:"
  echo "The following example scans files containing 'Clare' or 'Claire' and moves them to 'myFolder':"
  echo "copyfiles -m myFolder \"Clai?re\""
  echo ""
	echo "This will just output the names of files containing part of a ping sequence:"
	echo "copyfiles.sh -v \"icmp_seq=[0-9]{,3} ttl=[0-9]{,3}\""
  echo ""
	exit 1
}

# Boilerplate error handler from <https://stackoverflow.com/q/64786>
function error_exit {
	PROGNAME=$(basename $0) # Get program name
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2 # stdout to stderr, print line number of error
	exit 1
}

# Parameter handling
while getopts 'm:c:v' flag; do
  case "${flag}" in
    m) moveFlag="true"; moveFolder="${OPTARG}" ;;
    c) copyFlag="true"; moveFolder="${OPTARG}" ;;
    v) verbose="true" ;;
    \?) usage;;
  esac
done
shift $((OPTIND-1))

# Parameter checking
if [ -z "$1" ]; then #if no regex is provided
  usage
else
	userRegex=$1
fi
if $moveFlag && $copyFlag; then #if somehow trying to use both move and copy flags
  error_exit "The options -m and -c cannot be used together!"
fi


# Detect and place all valid TTY log files into an array
function getTTYLogFiles {
	TTYLogArray=() #declare array
	while IFS= read -r line; do
		TTYLogArray+=( "$line" ) #each line is a new array element
	done < <( ls | egrep '[0-9]{8}-[0-9]{6}-.{12}-.{2,3}.log' ) #Detect cowrie's tty-specific log files

	arraylength=${#TTYLogArray[@]} #get length of array
	if [ $arraylength -eq 0 ]; then
		error_exit "Error: no valid log files detected!"
	fi
}


# Play detected TTY log files to find a match in contents
function playTTYLogFiles {
	matchedPatternArray=()
	for (( i=0; i<${arraylength}; i++ )); do #step through array
		filename=${TTYLogArray[$i]}
    if $verbose; then
		    printf "\nScanning file: $filename"
		    printf "\nFile number: $[$i+1]\n"
      fi
		python playlog -m 0 $filename | egrep -q "$userRegex" && matchedPatternArray+=( "$filename" ) #search for matching pattern in logs, add matched files to array
	done
  if [ ${#matchedPatternArray[@]} -eq 0 ]; then #if empty
		error_exit "No files containing a match for that pattern were detected."
  fi
}


# What to do with files containing a match
function matchHandler {
	if $verbose; then #Output list of matched file names
		printf "\nThe following files contained a match:\n"; printf '%s\n' "${matchedPatternArray[@]}"
	fi
  printf "\n${#matchedPatternArray[@]} file(s) containing a match were detected.\n"
  if [[ $moveFlag || $copyFlag ]]; then
    printf "\nPreparing to move/copy...\n"
    if [ ! -d "$moveFolder" ]; then #If folder does not exist, create it
      mkdir $moveFolder || error_exit "Error: Permission needed to create that folder."
    fi
      # Copy the files
    if $moveFlag; then
      for matchedFiles in "${matchedPatternArray[@]}"; do
        mv $matchedFiles $moveFolder || error_exit "Unknown Error: Cannot move to folder $moveFolder!"
      done
      printf "Files were moved to folder $moveFolder\n" #if successful
    # Move the files
    elif $copyFlag; then
      for matchedFiles in "${matchedPatternArray[@]}"; do
        cp $matchedFiles $moveFolder || error_exit "Unknown Error: Cannot copy to folder $moveFolder!"
      done
        printf "Files were copied to folder $moveFolder\n" #if successful
    fi
  fi
}

#Try main functions, catch errors
(getTTYLogFiles; playTTYLogFiles; matchHandler) || error_exit "Exiting: an error has occured."
