===============================================================================

                       TP3 DEVOPS - MAKEFILE ARTISHOP

                            DOCUMENT DE LIVRABLE

===============================================================================



1. LIEN DE LA PULL REQUEST

-------------------------------------------------------------------------------

https://github.com/ZOUHAIRFGRA/fsr_ArtiShop/pull/3





2. SORTIE DE LA COMMAND "make help"

-------------------------------------------------------------------------------

$ make help

 make help       Affiche cette aide

 make install    Installe les dépendances du projet

 make start      Lance l'application en production

 make dev        Lance l'application en mode développement

 make test       Lance la suite de tests

 make clean      Supprime le dossier dist et les fichiers .log

 make health     Interroge la route health pour vérifier si le site répond

 make package    Construit l'archive à livrer

 make start-bg   Lance le serveur en arrière-plan

 make stop       Arrête le serveur en arrière-plan

 make status     Indique si le serveur tourne

 make restart    Redémarre le serveur

 make ci         Lance la chaîne d'intégration continue





3. GRILLE D'AUTO-ÉVALUATION

-------------------------------------------------------------------------------

[X] Toutes les cibles "actions" sont déclarées dans .PHONY

[X] Ports, dossiers et commandes sont dans des variables, en haut du fichier

[X] make install lancé deux fois de suite ne relance pas npm

[X] make package ne refait l'archive que si un fichier source a changé

[X] Aucune commande dupliquée

[X] make tout seul (ou make help) explique les cibles disponibles (bonus)





4. RÉPONSES AUX QUESTIONS DU TP

-------------------------------------------------------------------------------



--- PARTIE A : RÈGLES ET .PHONY ---



QA.1 : Remplacez la tabulation d'une commande par quatre espaces et lancez make.

       Quel message obtenez-vous ?

Réponse :

GNU Make affiche l'erreur : 

"Makefile:<numéro_ligne>: *** missing separator. Stop."

Cela s'explique par le fait que GNU Make exige obligatoirement une tabulation

(\t) au début des lignes de commande d'une règle.



QA.2 : À l'étape 3, pourquoi make test ne lançait-il pas les tests ?

Réponse :

Make compare le nom de la cible avec les fichiers présents dans le répertoire.

S'il existe un dossier ou fichier nommé "test" et qu'aucune dépendance n'a

changé, Make considère que la cible est déjà "à jour" et n'exécute pas la commande.

L'ajout de `.PHONY: test` indique explicitement à Make que "test" est une cible

fictive (une action) et non un fichier physique.



QA.3 : Quelle cible make lance-t-il quand on ne lui donne aucun argument ?

Réponse :

Make lance par défaut la première cible rencontrée dans le Makefile (dans notre

cas final, la cible `help`).





--- PARTIE B : VARIABLES ---



QB.1 : Remplacez PORT ?= 3000 par PORT := 3000, puis lancez `PORT=5000 make start`

       et `make start PORT=5000`. Sur quel port le site démarre-t-il dans chaque cas ?

       Expliquez la différence entre `?=` et `:=`.

Réponse :

- Avec `?= (affectation conditionnelle)` :

  - `PORT=5000 make start` -> démarre sur le port 5000 (la variable d'environnement surcharge `?=`).

  - `make start PORT=5000` -> démarre sur le port 5000 (l'argument en ligne de commande surcharge `?=`).

- Avec `:= (affectation simple / immédiate)` :

  - `PORT=5000 make start` -> démarre sur le port 3000 (`:=` écrase la variable d'environnement).

  - `make start PORT=5000` -> démarre sur le port 5000 (un argument explicite passé à make prime sur `:=`).

Explication : `?=` n'affecte la valeur que si la variable n'est pas déjà définie,

tandis que `:=` affecte immédiatement la valeur sans regarder l'environnement,

sauf si la variable est explicitement passée en argument en ligne de commande à Make.



QB.2 : Pourquoi écrire PORT=$(PORT) devant $(NPM) start ?

Réponse :

Cela permet de transmettre la variable `PORT` sous forme de variable d'environnement

au processus Node.js exécuté par npm. Ainsi, l'application peut lire `process.env.PORT`.



QB.3 : À quoi servent le `@` en début de commande et le `exit 1` de la cible health ?

Réponse :

- `@` évite que Make n'affiche lui-même la commande dans le terminal avant d'en

  exécuter le résultat (affichage propre).

- `exit 1` retourne un code d'erreur non nul (échec) au système afin que Make

  interrompe l'exécution et indique que la vérification de santé a échoué.





--- PARTIE C : INSTALLATION INCRÉMENTALE ---



QC.1 : Pourquoi faut-il `touch $@` après npm install ?

Réponse :

La commande `npm install` ne met pas toujours à jour la date de modification

(`mtime`) du dossier `node_modules`. Sans `touch $@`, la date du dossier reste

antérieure à `package.json`, et Make penserait à chaque fois que `node_modules`

est périmé et relancerait inutilement `npm install`.



QC.2 : Pourquoi est-il utile que start dépende de node_modules pour un nouveau développeur ?

Réponse :

Lorsqu'un nouveau développeur clone le projet, le dossier `node_modules` n'existe pas.

En faisant dépendre `start` de `node_modules`, l'exécution de `make start` installe

automatiquement toutes les dépendances via `npm install` avant de démarrer le serveur.





--- PARTIE D : FONCTIONS ET LIVRABLE ---



QD.1 : Pourquoi lire la version dans package.json plutôt que de l'écrire dans le Makefile ?

Réponse :

`package.json` constitue la source unique de vérité ("Single Source of Truth") du projet.

Lire la version dynamiquement évite la duplication d'information et empêche les incohérences

entre la version de l'application et le nom de l'archive générée.



QD.2 : À quoi sert le `|` devant $(DIST) ? Que risquerait-on sans lui ?

Réponse :

Le symbole `|` définit une dépendance d'ordre ("order-only dependency"). Cela garantit

que le dossier `dist/` est créé avant de créer l'archive, mais sans que les changements de

date du dossier `dist/` ne provoquent une re-création inutile de l'archive. Sans le `|`,

chaque modification de `dist/` reconstruirait l'archive en boucle.



QD.3 : Pourquoi node_modules n'est-il pas dans l'archive ?

Réponse :

Le dossier `node_modules` est très lourd et contient des binaires spécifiques au système d'exploitation.

L'exclure rend l'archive légère et portable. Les dépendances seront installées sur la machine cible à l'aide de `npm ci` ou `npm install`.





--- PARTIE E : CONDITIONS ---



QE.1 : Pourquoi utiliser `npm ci` plutôt que `npm install` sur un serveur d'intégration continue ?

       Faites le lien avec l'incident "PHP 7.4 en prod, 8.2 en dev".

Réponse :

`npm ci` installe les versions exactes définies dans `package-lock.json` de manière stricte

et reproductible, tout en supprimant le `node_modules` existant. À l'inverse, `npm install`

peut mettre à jour des sous-dépendances selon les plages de version du `package.json`.

Le lien avec l'incident est la dérive d'environnement ("environment drift") : utiliser

des versions différentes entre l'environnement de dev/CI et la prod provoque des bugs

inattendus. `npm ci` garantit le strict respect de l'environnement verrouillé.





--- PARTIE F : BONUS ET PILOTAGE DU SERVEUR ---



QF.1 : Pourquoi faut-il écrire `$$!` et `$$(cat...)` au lieu de `$!` et `$(cat ...)` ?

Réponse :

Dans un Makefile, le symbole `$` sert à évaluer les variables de Make. Pour transmettre

un véritable `$` au shell sous-jacent (pour lire le PID `$!` ou exécuter une commande bash

`$(cat ...)`), il faut doubler le symbole (`$$`) afin que Make l'échappe.



QF.2 : Pourquoi lancer `$(NODE) src/server.js` plutôt que `$(NPM) start` dans start-bg ?

Réponse :

`npm start` lance un processus englobant (wrapper). Le PID récupéré avec `$!` serait celui

du CLI `npm` et non du serveur Node.js. En lançant directement `node src/server.js`, `$!`

capture le vrai PID du serveur Node, ce qui permet de le contrôler et de l'arrêter proprement (`kill`).



QF.3 : Pourquoi restart appelle-t-il `$(MAKE)` deux fois au lieu de s'écrire `restart: stop start-bg` ?

Réponse :

En appelant `$(MAKE) stop` puis `$(MAKE) start-bg`, on force deux exécutions séquentielles

et indépendantes de Make. Écrire `restart: stop start-bg` permettrait à Make d'exécuter

les dépendances selon son propre ordonnancement, risquant de démarrer le nouveau serveur

avant que l'ancien ne soit totalement arrêté.

===============================================================================