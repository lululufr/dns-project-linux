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
    
    if id -u "$username" >/dev/null 2>&1; then
        username="${username}1"
    fi
    
    useradd -p "$(openssl passwd -1 "$password")" -c "$prenom $nom" -m "$username"
    chage -d 0 "$username"
    
    IFS=',' read -ra GROUP <<< "$groupes"
    for i in "${GROUP[@]}"; do
        if ! getent group "$i" >/dev/null 2>&1; then
            groupadd "$i"
        fi
        usermod -a -G "$i" "$username"
    done
    
    if [ "$sudo" = "oui" ]; then
        usermod -aG sudo "$username"
    fi

done < "$fichier_utilisateurs"

echo "Les utilisateurs de votre fichier ont été créés"
