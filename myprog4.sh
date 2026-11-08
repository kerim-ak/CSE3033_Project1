#!/bin/bash

# Require exactly one directory argument.
if [ "$#" -ne 1 ]; then
    echo "Usage: bash myprog4.sh <directory>" >&2
    exit 1
fi

# Check that the argument points to a directory.
klasor="$1"
if [ ! -d "$klasor" ]; then
    echo "Error: '$klasor' is not a directory." >&2
    exit 1
fi

# Create both destination directories.
if ! mkdir -p -- "$klasor/large_files" "$klasor/small_files"; then
    echo "Error: Could not create the destination directories." >&2
    exit 1
fi

# Include hidden files in the directory scan.
shopt -s dotglob

# Use 1,000,000 bytes as the 1 MB limit.
sinir=1000000
buyuk_sayac=0
kucuk_sayac=0
hata=0

for dosya in "$klasor"/*; do
    # Skip directories and other entries that are not regular files.
    if [ ! -f "$dosya" ] || [ -L "$dosya" ]; then
        continue
    fi

    # Read the file size in bytes.
    if ! boyut=$(stat -c %s -- "$dosya"); then
        hata=1
        continue
    fi

    # Send files at or below the limit to small_files.
    if [ "$boyut" -gt "$sinir" ]; then
        hedef_klasor="large_files"
    else
        hedef_klasor="small_files"
    fi

    # Keep the original filename and skip existing destinations.
    dosya_adi="${dosya##*/}"
    hedef="$klasor/$hedef_klasor/$dosya_adi"

    if [ -e "$hedef" ] || [ -L "$hedef" ]; then
        echo "Error: Destination already exists: '$hedef'." >&2
        hata=1
        continue
    fi

    # Count only successful moves.
    if mv -- "$dosya" "$klasor/$hedef_klasor/"; then
        if [ "$hedef_klasor" = "large_files" ]; then
            buyuk_sayac=$((buyuk_sayac + 1))
        else
            kucuk_sayac=$((kucuk_sayac + 1))
        fi
    else
        hata=1
    fi
done

# Print the totals and report whether any operation failed.
echo "$buyuk_sayac files moved to large_files"
echo "$kucuk_sayac files moved to small_files"
exit "$hata"