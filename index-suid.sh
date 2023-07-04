#!/bin/bash

nvfic="/tmp/nouveau-linux-exam-suidguid.txt"
vific="/tmp/vieux-linux-exam-suidguid.txt"

find / -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null > "$nvfic"

if [ -f "$vific" ]; then
    diff=$(diff "$nvfic" "$vific")
    if [ -n "$diff" ]; then
        echo "Attention, DETECTION D'UN CHANGEMENT !!!!!"
        echo "$diff"
        echo "Dates de modification des fichiers concernés :"


        for file in $(echo "$diff" | awk '/</ {print $2}'); do
            stat -c '%y' "$file"
        done
    fi
fi

mv "$nvfic" "$vific" #on renomme 
