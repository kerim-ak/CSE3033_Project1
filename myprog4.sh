#!/bin/bash

# Require exactly one directory argument.
if [ "$#" -ne 1 ]; then
    echo "Usage: bash myprog4.sh <directory>" >&2
    exit 1
fi

# Check that the argument points to a directory.
target_dir="$1"
if [ ! -d "$target_dir" ]; then
    echo "Error: '$target_dir' is not a directory." >&2
    exit 1
fi

# Create both destination directories.
if ! mkdir -p -- "$target_dir/large_files" "$target_dir/small_files"; then
    echo "Error: Could not create the destination directories." >&2
    exit 1
fi

# Include hidden files in the directory scan.
shopt -s dotglob

# Use 1,000,000 bytes as the 1 MB limit.
size_limit=1000000
large_count=0
small_count=0
had_error=0

for file in "$target_dir"/*; do
    # Skip directories and other entries that are not regular files.
    if [ ! -f "$file" ] || [ -L "$file" ]; then
        continue
    fi

    # Read the file size in bytes.
    if ! size_bytes=$(stat -c %s -- "$file"); then
        had_error=1
        continue
    fi

    # Send files at or below the limit to small_files.
    if [ "$size_bytes" -gt "$size_limit" ]; then
        destination_dir="large_files"
    else
        destination_dir="small_files"
    fi

    # Keep the original filename and skip existing destinations.
    filename="${file##*/}"
    destination="$target_dir/$destination_dir/$filename"

    if [ -e "$destination" ] || [ -L "$destination" ]; then
        echo "Error: Destination already exists: '$destination'." >&2
        had_error=1
        continue
    fi

    # Count only successful moves.
    if mv -- "$file" "$target_dir/$destination_dir/"; then
        if [ "$destination_dir" = "large_files" ]; then
            large_count=$((large_count + 1))
        else
            small_count=$((small_count + 1))
        fi
    else
        had_error=1
    fi
done

# Print the totals and report whether any operation failed.
echo "$large_count files moved to large_files"
echo "$small_count files moved to small_files"
exit "$had_error"