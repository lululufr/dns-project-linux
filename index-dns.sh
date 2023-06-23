#!/bin/bash



cheminfic="/chemin/vers/votre/fichier.txt"

# Lecture du fichier ligne par ligne
while IFS= read -r ligne
do
    # Comparaison avec le contenu précédent
    if [[ "$ligne" == "votre_condition" ]]; then
        echo "Correspondance trouvée: $ligne"
        # Faites ce que vous souhaitez avec la correspondance trouvée
    fi
    
    # Faites d'autres opérations avec la ligne
    
done < "$cheminfic"
