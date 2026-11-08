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
if ! tarih=$(date +%F); then
    echo "Error: Could not determine today's date." >&2
    exit 1
fi

backup_folder_name="backup_$tarih"
yedek_klasoru="$target_dir/$backup_folder_name"

# Create the backup directory or reuse it if it already exists.
if ! mkdir -p -- "$yedek_klasoru"; then
    echo "Error: Could not create backup directory '$yedek_klasoru'." >&2
    exit 1
fi

# Skip patterns that match no files.
shopt -s nullglob

sayac=0
hata=0

# Copy regular .txt and .sh files and count successful copies.
for dosya in "$target_dir"/*.txt "$target_dir"/*.sh; do
    if [ -f "$dosya" ]; then
        if cp -- "$dosya" "$yedek_klasoru/"; then
            sayac=$((sayac + 1))
        else
            hata=1
        fi
    fi
done

# Print the total and return an error if any copy failed.
echo "$sayac files copied into $backup_folder_name"
exit "$hata"