#!/bin/bash

new_file="/tmp/new_suid_sgid_files.txt"
old_file="/tmp/old_suid_sgid_files.txt"

find / -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null > "$new_file"

if [ -f "$old_file" ]; then
    diff_output=$(diff "$new_file" "$old_file")
    if [ -n "$diff_output" ]; then
        echo "Attention, les fichiers SUID/SGID ont changé :"
        echo "$diff_output"
        echo "Dates de modification des fichiers concernés :"
        for file in $(echo "$diff_output" | awk '/</ {print $2}'); do
            stat -c '%y' "$file"
        done
    fi
fi

mv "$new_file" "$old_file"
