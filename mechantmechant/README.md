Membres: Titou, charly, Idris, Carlo, Nico

Idée générale : Programme qui exfiltre les données (fichier ou texte) entrées dans le presse-papier de la victime et qui prend une capture d'écran quand l'utilisateur colle ces données.

Comportement détaillé : Le programme doit tourner en tâche de fond, en tant que service, et s'intégrer dans les programmes lancés au démarrage pour la persistence. Lorsque la victime copie du texte ou un fichier (penser à mettre une taille limite de fichier pour éviter d'exfiltrer des dossiers de 50Go), le fichier est envoyé sur un C2 par un web socket. Lorsque la victime colle du texte ou un fichier (penser à mettre un court délai ± 0.5s pour que la copie aie le temps de se faire si c'est un gros truc) une capture d'écran est prise et exfiltrée au C2 de la même manière. Les exfiltrations seront horodatées. Si possible, obfusquer le programme en le divisant en plusieurs sous-services.


### Run le projet

Se placer dans le projet rust "mechantmechant"

 ```sh
 cargo build
 cargo run
 ```

 Pour build une version de production (executable) disponible dans target/release/

 ```sh
 cargo build --release
```
