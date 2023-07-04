#!/bin/bash


# Calcul de la taille
declare -A sizes

while IFS=: read -r username _; do
    if [[ -d "/home/$username" ]]; then
        size=$(du -sBM "/home/$username" | awk '{print $1}')
        sizes[$username]=$size
    fi
done < <(cut -d: -f1,6 /etc/passwd)

# Tri cocktail
tab=(${sizes[@]})

echange=true
while [ "$echange" = true ]
do
    echange=false

    for i in $(seq 0 $((${#tab[@]} - 2)))
    do
        value1=${tab[$i]//[!0-9]/}
        value2=${tab[$((i+1))]//[!0-9]/}
        
        if [ $value1 -lt $value2 ]
        then
            tmp=${tab[$i]}
            tab[$i]=${tab[$((i+1))]}
            tab[$((i+1))]=$tmp
            echange=true
        fi
    done
    
    for i in $(seq $((${#tab[@]} - 2)) -1 0)
    do
        value1=${tab[$i]//[!0-9]/}
        value2=${tab[$((i+1))]//[!0-9]/}
        
        if [ $value1 -lt $value2 ]
        then
            tmp=${tab[$i]}
            tab[$i]=${tab[$((i+1))]}
            tab[$((i+1))]=$tmp
            echange=true
        fi
    done
done

echo "${tab[@]}"

# Affichage des 5 
echo "Les 5 plus gros consommateurs d'espace disque :"

for ((i = 0; i < 5 && i < ${#tab[@]}; i++)); do
    username=${tab[$i]}
    size=${sizes[$username]}
    formatted_size=($size)
    echo "$(($i + 1)). $username"
    #echo "$(find /home -size ${tab[i]})"
done

# Modification du fichier .bashrc
for username in "${tab[@]}"; do
    bashrc_file="/home/$username/.bashrc"

    if [[ -f "$bashrc_file" ]]; then
        
        echo 'echo "Taille du répertoire personnel : $(du -sh ~ | cut -f1) ($(du -sB1 ~ | cut -f1) octets)"' >> "$bashrc_file"

        # Vérif de la taille
        echo 'if (( $(du -sBM ~ | cut -f1) > 100 )); then' >> "$bashrc_file"
        echo '    echo "ATTENTION : + 100 Mo." >&2' >> "$bashrc_file"
        echo 'fi' >> "$bashrc_file"
    fi
done