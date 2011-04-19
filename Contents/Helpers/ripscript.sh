#!/bin/bash

# Error Codes
NO_HANDBRAKE="10"
NO_VLC="11"
NO_OUTPUT_DIR="12"
NO_DVD="13"

# Check if HandbrakeCLI is installed
if ! [ -e "/Applications/HandBrakeCLI" ]
then
	echo $NO_HANDBRAKE
	exit
fi

# Check if VLC is installed
if ! [ -e "/Applications/VLC.app" ]
then
	echo $NO_VLC
	exit
fi

# Check if output directory exists
if ! [ -e $1 ]
then
	echo $NO_OUTPUT_DIR
	exit
fi

# We need to get the dynamic path to the DVD
dvdpath=$(mount | grep udf | awk '{print $3}')

# Exit if no DVD found
if [ -z $dvdpath ]
then
	echo $NO_DVD
	exit
fi

# Construct and execute the command
if [ $6 == "True" ]
then
	# This is the output directory. Check if it exists, create it if not, then append the filename.
	outputpath="$1""$7"
	if [ ! -d "$outputpath" ]
		then
			mkdir "$outputpath"
	fi
	outputpath=$outputpath"/"$2
else
	outputpath="$1""$2"
fi

if [ $8 == "None" ]
then
	command="/Applications/HandBrakeCLI -i $dvdpath -o \"$outputpath\" --preset=\"$5\" -L"
else
	command="/Applications/HandBrakeCLI -i $dvdpath -o \"$outputpath\" --preset=\"$5\" -L -N $8"
fi

logpath="/Users/"$USER"/Desktop/videorip.txt"

# If logging is on output to logpath otherwise redirect stdout and stderr to /dev/null
if [ $4 == "True" ]
then
	eval "$command" &> $logpath
else
	eval "$command" &> /dev/null
fi

# Eject the disc if requested
if [ $3 == "True" ]
then
	drutil tray eject 1
fi	

echo "0"
exit