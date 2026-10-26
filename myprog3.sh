#!/bin/bash

#checking argument count
if [ $# -ne 3 ]; then
	echo "Incorrect usage!"
	echo "Correct usage: $0 <FileName> <wordToBeReplaced> <wordToBePlaced>"
	exit 1
fi


#checking if the file exists.
#this time used double brackets instead of quoting $1.
#double brackets is a compound command built in bash. this command uses a specialized parser.
#even if the file name has spaces or it is empty, this command handles these cases.
if [[ ! -f $1 ]]; then
	echo "Error: File '$1' not found."
    exit 1
fi

#counting the encounters of the first word withing the file
#-o flag ensures that grep returns all instances, not just the lines.
count=$(grep -o "$2" "$1" | wc -l | tr -d ' ')

#if there is no match, following message printed
if [ "$count" -le 0 ]; then
	echo "No $2 encountered within file $1"
	exit 0
fi

#defining the variables since it has gotten so hard to read
target="$2"
replacement="$3"
input_file="$1"
output_file="modified_$1"
log_file="changes.log"

#else, the replacement will occur
#sed is a stream editor and it has a built-in search-and-replace feature
#used > since i want to keep the most recent version of the modified output file
#used |'s as delimiters since they are less common
#there still be some errors when | char used in target or replacement
#this can be dealt with by using awk
sed "s|$target|$replacement|g" "$input_file" > "$output_file"

#used >> since i want to keep track of all the changes made to the file"
echo "$target -> $replacement in $input_file, count: $count" >> "$log_file"

echo "All $count occurrences of '$target' replaced with '$replacement'"
echo "Modified file: modified_$1"
echo "Logged to: $log_file"