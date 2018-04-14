#!/bin/bash
# UP819474
# DESCRIPTION OF WHAT THIS DOES HERE


# Declaration of options
verbose="false"
moveFlag="false"
copyFlag="false"


# Displays help and then exits
function usage {
  echo ""
  echo "Syntax:"
  echo "copyfiles [-v] [{-c|-v} Foldername] [\"Pattern\"]"
  echo ""
  echo "Options:"
  echo "-v | --verbose # Output files containing match to console (verbose mode)."
  echo "-m | --move    # Specify where to move matched files (cannot be used with -c | --move)."
  echo "-c | --copy    # Specify where to copy matched files (cannot be used with -m | --move)."
  echo ""
  echo "Usage examples:"
  echo "The following example scans files containing 'Clare' or 'Claire' and moves them to 'myFolder':"
  echo "copyfiles -m myFolder \"Clai?re\""
  echo ""
	echo "This will just output the names of files containing part of a ping sequence:"
	echo "copyfiles -v \"icmp_seq=[0-9]{,3} ttl=[0-9]{,3}\""
  echo ""
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
	echo "$userRegex"
fi
if $moveFlag && $copyFlag; then #if somehow trying to use both move and copy flags
  echo "$0: The options -m and -c cannot be used together!" 1>&2; exit 1
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
		printf "\nFile name: $filename"
		printf "\nFile number: $[$i+1]\n" #number starting at 1
		#python playlog -m 0 $filename | egrep -Z "$userRegex" #DEBUG
		python playlog -m 0 $filename | egrep -q "$userRegex" && matchedPatternArray+=( "$filename" ) #search for matching pattern in logs, add matched files to array
	done

}


# What to do with files contain a match
function matchHandler {

	if [ ${#matchedPatternArray[@]} -eq 0 ]; then #if empty
		printf "\nThis should be empty:\n"; printf '%s\n' "${matchedPatternArray[@]}" #DEBUG
		error_exit "No files containing a match for that pattern were detected. :("
	else
		printf "\n${#matchedPatternArray[@]} file(s) containing a match were detected.\n"
		if $verbose; then
			printf "\nThe following files contained a match:\n"; printf '%s\n' "${matchedPatternArray[@]}"
		fi
	fi

}


# Boilerplate error "handler" from <https://stackoverflow.com/q/64786>
function error_exit {

	PROGNAME=$(basename $0) # Get program name
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2 # stdout to stderr
	exit 1

}


(getTTYLogFiles; playTTYLogFiles; matchHandler) || error_exit "Exiting: an error has occured."

printf "\n\nUser Input: $userRegex\n" #DEBUG

# NOTES FOR LATER REFERENCE

# Note that certain input for egrep need an escape character: i.e. a comma: \,

# grep -H "pattern" "file" = return file name of matched string

# grep -z "pattern" = output all text with matching patterns highlighted

# grep -q "pattern" = no output, only exit code.

# xargs grep -H "text" = as above

# Must use playlog as .log files are not in format parsable with tools like cat

# ? tests exit code of last command (0 for success, 1 for failure) (i.e. echo $?)

# $0, $1, $2 etc. = positional parameters
# i.e. ./script.sh Hello world
# $0 = script.sh
# $1 = Hello
# $2 = world

# python playlog -m 0 ${TTYLogArray[$i]} | grep -q "$userRegex" # play logs with no input delay
