## MéchantMéchant

## Projet

### Idée générale : Programme qui exfiltre les données (fichier ou texte) entrées dans le presse-papier de la victime et qui prend une capture d'écran quand l'utilisateur colle ces données.

Comportement détaillé : Le programme doit tourner en tâche de fond, en tant que service, et s'intégrer dans les programmes lancés au démarrage pour la persistence. Lorsque la victime copie du texte ou un fichier (penser à mettre une taille limite de fichier pour éviter d'exfiltrer des dossiers de 50Go), le fichier est envoyé sur un C2 par un web socket. Lorsque la victime colle du texte ou un fichier (penser à mettre un court délai ± 0.5s pour que la copie aie le temps de se faire si c'est un gros truc) une capture d'écran est prise et exfiltrée au C2 de la même manière. Les exfiltrations seront horodatées. Si possible, obfusquer le programme en le divisant en plusieurs sous-services.

### Fonctionnel

A l'heure actuelle, l'executable va envoyer les données copier dans le presse-papier au serveur distant. Lorsqu'une nouvelle valeure est répérée, il va screenshot l'intégralité des fénêtres ouvertes sur la session, les horodatés, et les stocker dans le dossier SCREENS/.

### Prerequis 

Avoir un dossier "SCREENS" à la racine de l'exe, tel que MechantMechant/mechantmechant/target/release/SCREENS/.

### Execution

Lancer un serveur web-socket en local qui écoute sur le port spécifié, pour cela éxecuter le fichier python serveur.py dans MechantMechant/web-socket/.
```sh
python serveur.py
```

Puis lancer le script mechantmechant.exe (dans MechantMechant/mechantmechant/target/release/mechantmechant.exe).
```sh 
./mechantmechant.exe
```

### Equipe 

Matière: Cybersécurité des OS
Membres: Titou, charly, Idris, Carlo, Nico, Joseph
