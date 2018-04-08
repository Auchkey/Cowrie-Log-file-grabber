#!/bin/bash
# UP819474
# Copies event log files matching regex into /cowrie/log/matchedtty/*foldername*
# TODO: get regex input from user, scan TTYlogs and put files with matched content in separate directory for easy examination later.


# mkdir -p ../log/matchedtty/test
# cd ../log/tty


# Place all valid TTY .log files into an array
function getTTYLogFiles() {

	TTYLogArray=() # declare array
	while IFS= read -r line; do
		TTYLogArray+=( "$line" ) # each line is a new array element
	done < <( ls | egrep '[0-9]{8}-[0-9]{6}-.{12}-.{2,3}.log' ) # ls and grep instead of find to keep logs in order of date
	
}



function playTTYLogFiles() {
	
	arraylength=${#TTYLogArray[@]} # get length of array
	for (( i=0; i<${arraylength}; i++ )); do # step through array
		printf "\nFile name: ${TTYLogArray[$i]}"
		printf "\nFile number: $[$i+1]\n"
		python playlog -m 0 ${TTYLogArray[$i]} # play logs with no input delay
	
	done

}

(getTTYLogFiles && playTTYLogFiles) || echo "There was an error." # will hopefully be more helpful later


# grep -H "text" "file" = return file name of matched string

# xargs grep -H "text" = as above

# Must use playlog as .log files are not in format parsable with tools like cat

#? tests exit code of last command (0 for success, 1 for failure)

