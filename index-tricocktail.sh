#!/bin/bash

# Fonction pour afficher la taille formatée en Go, Mo, Ko et octets
format_size() {
    local size=$1
    local unit="octets"

    if [[ $size == *M ]]; then
        size=${size%M}
        unit="Mo"
    fi

    if ((size >= 1024)); then
        size=$(bc <<< "scale=2; $size / 1024")
        unit="Go"
    fi

    if ((size >= 1024)); then
        size=$(bc <<< "scale=2; $size / 1024")
        unit="To"
    fi

    printf "%.2f%s" "$size" "$unit"
}




# Calcul de la taille des répertoires personnels
declare -A sizes

while IFS=: read -r username _; do
    if [[ -d "/home/$username" ]]; then
        size=$(du -sBM "/home/$username" | awk '{print $1}')
        sizes[$username]=$size
    fi
done < <(cut -d: -f1,6 /etc/passwd)



# Tri cocktail des utilisateurs en fonction de la taille


tab=${sizes[@]}
# Affichage du tableau

echo "${sizes[@]}"


echange=true
while [ "$echange" = true ]
do
    echange=false

    for i in $(seq 0 $((${#tab[@]} - 2)))
    do
        if [ ${tab[$i]} -lt ${tab[$((i+1))]} ]
        then
            tmp=${tab[$i]}
            tab[$i]=${tab[$((i+1))]}
            tab[$((i+1))]=$tmp
            echange=true
        fi
    done

    for i in $(seq $((${#tab[@]} - 2)) -1 0)
    do
        if [ ${tab[$i]} -lt ${tab[$((i+1))]} ]
        then
            tmp=${tab[$i]}
            tab[$i]=${tab[$((i+1))]}
            tab[$((i+1))]=$tmp
            echange=true
        fi
    done
done

echo "${tab[@]}"


# Affichage des 5 plus gros
echo "5 plus gros consommateurs d'espace:"

for ((i = 0; i < 5 && i < ${#users[@]}; i++)); do
    username=${users[$i]}
    size=${sizes[$username]}
    formatted_size=$(format_size $size)
    echo "$(($i + 1)). $username : $formatted_size"
done

# Modification du fichier .bashrc de chaque utilisateur
for username in "${users[@]}"; do
    bashrc_file="/home/$username/.bashrc"

    if [[ -f "$bashrc_file" ]]; then
        # Ajout de la commande pour afficher la taille du répertoire personnel
        echo 'echo "Taille du repertoire  : $(du -sh ~ | cut -f1)"' >> "$bashrc_file"
	# Verif taille
        echo 'if (( $(du -sBM ~ | cut -f1) > 100 )); then' >> "$bashrc_file"
        echo 'echo "AVERTISSEMENT : répertoire +  100 M" >&2' >> "$bashrc_file"
        echo 'fi' >> "$bashrc_file"    

fi
done
