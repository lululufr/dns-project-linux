#!/bin/bash

noms=("Dufresn" "Morales" "Bathily" "Miller" "Elefteriou" "Bossboeuf" "Paris" "Sissoko" "Uzumaki" "Miyamoto" "Bienveillance")
prenoms=("Désiré" "Alexis" "Delphine" "Backary" "Yvann" "Précieux" "Sublime" "Lucas" "Bob" "Quentin" "Perceval" "Cyrano" "Ping")


nom=${noms[$RANDOM % ${#noms[@]}]}
prenom=${prenoms[$RANDOM % ${#prenoms[@]}]} #génération aléatoire d'un nom et d un prenom


echo "Nom : $nom"
echo "Prénom : $prenom"

login="${prenom:0:1}${nom}"

echo "$login"
