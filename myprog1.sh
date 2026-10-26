#!/bin/bash

#argument count check
#[ ... ] is an alias for test
#-ne flag: not equal
#there has to be spaces after the opening bracket and before the closing bracket
#after specifying the condition of the if statement, then keyword has to be used.""
if [ $# -ne 2 ]; then
	echo "Incorrect usage!"
	echo "Correct usage: $0 <logFileName> [LogLevel]"
	exit 1
fi

#file check
#-f flag ensures that the file exist in the specified location and not a directory or a symlink
if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found."
    exit 1
fi

#level check
#multiple tests to check the level text
if [ "$2" != "INFO" ] && [ "$2" != "WARNING" ] && [ "$2" != "ERROR" ]; then
	echo "Invalid log level!"
	echo "Valid levels: INFO, WARNING, ERROR."
	exit 1
fi

#storing the number of lines found
#-c flag of grep returns the number of lines grepped
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