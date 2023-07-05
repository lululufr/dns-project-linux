#!/bin/bash

echo "Bonjour que voulez vous faire ?"
echo "1 - Supprimer les utilisateurs du fichier"
echo "2 - Creer les utilisateurs du fichier"

read choice




    if [ $# -ne 1 ]; then
        echo "Veuillez renseigner le nom du fichier"
        echo " la commande s'utilise comme suis : $0 <fichier.avec.les.utilisateurs>"
        exit 1
    fi

    fichier_usr=$1

    if [ ! -f "$fichier_usr" ]; then
        echo "$fichier_utilisateur n'est pas valide !!!!"
        exit 1
    fi



if [ $choice -eq "2" ]; then


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
            usermod -aG sudo "$username" #les AG permettent de garder les groupes actuelle dans supprimer les autres et G de placer plusieurs groupe
        fi


    # création de fichiers aléatoires
        for i in $(seq $((RANDOM%6+5))); do
            fallocate -l $((RANDOM%46+5))M /home/"$username"/file"$i"
        done



    done < "$fichier_usr"

    echo "Les utilisateurs de votre fichier ont été créés"
fi

if [ $choice -eq 1 ]; then


    while IFS=':' read -r prenom nom groupes sudo password; do
        username=$(echo "${prenom:0:1}${nom}" | tr '[:upper:]' '[:lower:]')
        
        deluser "$username"

        rm -rd /home/"$username"

    done < "$fichier_usr"

    echo "Les utilisateurs de votre fichier ont été SUPPRIME  !!"

fi