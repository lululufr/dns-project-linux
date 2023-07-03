#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Veuillez renseigner le nom du fichier"
    echo " la commande s'utilise comme suis : $0 <fichier.avec.les.utilisateurs>"
    exit 1
fi

fichier_utilisateurs=$1

if [ ! -f "$fichier_utilisateurs" ]; then
    echo "$fichier_utilisateur n'est pas valide !!!!"
    exit 1
fi


#lecture du fichier avec comme séparateur le : 
#le tr permet de tout mettre toutes les majuscule en minuscule
while IFS=':' read -r prenom nom groupes sudo password; do
    username=$(echo "${prenom:0:1}${nom}" | tr '[:upper:]' '[:lower:]')
    
    useradd -p "$(openssl passwd -1 "$password")" -c "$prenom $nom" -m "$username"
    chage -d 0 "$username"

#les groupes !!!
    
    IFS=',' read -ra GROUP <<< "$groupes"
    for i in "${GROUP[@]}"; do
        if ! getent group "$i" >/dev/null 2>&1; then
            groupadd "$i"
        fi
        usermod -a -G "$i" "$username"
    done
    

#sudo ou non 
    if [ "$sudo" = "oui" ]; then
        usermod -aG sudo "$username"
    fi


# création de fichiers aléatoires
    for i in $(seq $((RANDOM%6+5))); do
        fallocate -l $((RANDOM%46+5))M /home/"$username"/file"$i"
    done



done < "$fichier_utilisateurs"

echo "Les utilisateurs de votre fichier ont été créés"
