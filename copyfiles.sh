#!/bin/bash
# UP819474
# DESCRIPTION OF WHAT THIS DOES HERE
# TODO: get regex input from user, scan TTYlogs and put files with matched content in separate directory for easy examination later.

userRegex=$*

#function getRegexPattern() {

	

#}



# Place all valid TTY log files into an array
function getTTYLogFiles() {

	TTYLogArray=() # declare array
	while IFS= read -r line; do
		TTYLogArray+=( "$line" ) # each line is a new array element
	done < <( ls | egrep '[0-9]{8}-[0-9]{6}-.{12}-.{2,3}.log' ) # regex to detect cowrie's tty-specific log files

	arraylength=${#TTYLogArray[@]} # get length of array
	if [ $arraylength -eq 0 ]; then
		error_exit "Error: no valid log files detected!"
	fi

}


# Play detected TTY log files
function playTTYLogFiles() {
	
	for (( i=0; i<${arraylength}; i++ )); do # step through array
		printf "\nFile name: ${TTYLogArray[$i]}"
		printf "\nFile number: $[$i+1]\n" # number starting at 1
		python playlog -m 0 ${TTYLogArray[$i]} | egrep "$userRegex" # search for matching pattern in logs
	
	done

}



# Boilerplate error "handler" from <https://stackoverflow.com/q/64786>
function error_exit {
	
	PROGNAME=$(basename $0) # Get program name
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1	

}



(getTTYLogFiles && playTTYLogFiles) #|| error_exit "$LINENO Program exiting: an error has occured."

printf "\n\nUser Input: $userRegex\n"

# NOTES FOR LATER REFERENCE

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
