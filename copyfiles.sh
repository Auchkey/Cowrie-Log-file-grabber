#!/bin/bash
#UP819474
#Copies event log files matching regex into /cowrie/log/matchedtty/*foldername*

#mkdir -p ../log/matchedtty/test

cd ../log/tty

ls -l | grep -E +.log$ | cut -c 45-79 | xargs python ../../bin/playlog -m 0


# list directory, extended grep (for regex) to only return .log files, cut to file name (which is always characters 45 to 79), then play each log

#"playlog -m 0" = instant ouput

# must cut to only file name: current -l prints sizes, dates, permissions etc...


