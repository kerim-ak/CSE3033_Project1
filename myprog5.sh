#!/bin/bash

#checking argument count
if [ $# -ne 2 ]; then
	echo "Incorrect usage!"
	echo "Correct usage: $0 <Directory> <Prefix>"
	exit 1
fi

target_dir="$1"
prefix="$2"

#checking if the directory exists
if [[ ! -d $target_dir ]]; then
	echo "Error: Directory '$target_dir' not found or it is not a directory."
    exit 1
fi

#finding the number of subdirectories.
#-mindepth is for not counting the current directory.
#type -d is for only looking for directories.
subdir_count=$(find "$target_dir" -mindepth 1 -type d | wc -l | tr -d ' ')

#checking whether the main directory has subdirectories. if so, set a flag.
if [ "$subdir_count" -gt 0 ]; then
	has_subdirs=true
	echo "Subdirectories found in '$target_dir'."
else
	has_subdirs=false
fi



#if subdirectories exists, prompt user for confirmation.
if [ "$has_subdirs" = true ]; then
    #input
    read -p "Subdirectories found. Rename files recursively? (y/n): " answer

    #accepting y, yes, YES...
	#*) means any other thing, it is a wildcard.
	#;; means break
    case "$answer" in
        [yY]|[yY][eE][sS])
            recursive=true
            ;;
        *)
            recursive=false
            ;;
    esac
fi

#to be able to shape the command more clearly, structure command as a variable.
find_cmd=(find "$target_dir")

if [ "$recursive" = false ]; then
    find_cmd+=(-maxdepth 1)
fi

#-type f for only looking for files & not counting the ones with the prefix already applied.
find_cmd+=(-type f -name "*.txt" ! -name "${prefix}*.txt")

renamed_files=()
count=0

# Use process substitution and read -r -d '' to safely handle filenames with spaces
#resetting IFS (internal field seperator) to be able to read the files with whitespaces in their names
#using it right before read command makes this change only for this line, which means after this line, IFS goes back to its default value
#-r raw flag: just read as is
#-d '' sets delimiter to null
while IFS= read -r -d '' file; do
    dir=$(dirname "$file")
    base=$(basename "$file")
    new_name="${prefix}${base}"
    new_path="$dir/$new_name"

    #rename the file
    mv "$file" "$new_path"

    #save the new filename and increment counter
    renamed_files+=("$new_name")
    (( count++ ))
done < <("${find_cmd[@]}" -print0)

#if no files renamed, print message
if [ "$count" -eq 0 ]; then
    echo "0 files renamed."
    exit 0
fi

#set IFS again to seperate files with a comma and a space.
IFS=', '
#creating a list of renamed files
file_list="${renamed_files[*]}"
#restore IFS back to initial value.
unset IFS

#finale message
echo "$count files renamed: $file_list"