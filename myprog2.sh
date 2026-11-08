#!/bin/bash

# Require exactly one directory argument.
if [ "$#" -ne 1 ]; then
    echo "Usage: bash myprog2.sh <directory>" >&2
    exit 1
fi

# Check that the provided path is a directory.
target_dir="$1"
if [ ! -d "$target_dir" ]; then
    echo "Error: Directory '$target_dir' not found." >&2
    exit 1
fi

# Build the backup directory name using today's date.
if ! date_stamp=$(date +%F); then
    echo "Error: Could not determine today's date." >&2
    exit 1
fi

backup_folder_name="backup_$date_stamp"
backup_dir="$target_dir/$backup_folder_name"

# Create the backup directory or reuse it if it already exists.
if ! mkdir -p -- "$backup_dir"; then
    echo "Error: Could not create backup directory '$backup_dir'." >&2
    exit 1
fi

# Skip patterns that match no files.
shopt -s nullglob

copied_count=0
had_error=0

# Copy regular .txt and .sh files and count successful copies.
for file in "$target_dir"/*.txt "$target_dir"/*.sh; do
    if [ -f "$file" ]; then
        if cp -- "$file" "$backup_dir/"; then
            copied_count=$((copied_count + 1))
        else
            had_error=1
        fi
    fi
done

# Print the total and return an error if any copy failed.
echo "$copied_count files copied into $backup_folder_name"
exit "$had_error"