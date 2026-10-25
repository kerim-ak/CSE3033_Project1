#!/bin/bash

#argument count check
if [ $# -ne 2 ]; then
	echo "Incorrect usage!"
	echo "Correct usage: $0 <logFileName> [LogLevel]"
	exit 1
fi

#file check
if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found."
    exit 1
fi

#level check
if [ "$2" != "INFO" ] && [ "$2" != "WARNING" ] && [ "$2" != "ERROR" ]; then
	echo "Invalid log level!"
	echo "Valid levels: INFO, WARNING, ERROR."
	exit 1
fi

#storing the number of lines found
count=$(grep -c "$2" "$1")

#if there is no match, following message printed
if [ $count -le 0 ]; then
	echo "No log matching $2 level."
	exit 0
fi

#standard flow
echo "Matching log entries:"
grep "$2" "$1"
echo "Total $2 entries: $count"