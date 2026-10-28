# TP1 ArtiShop : réponses et exécution

Fork : https://github.com/ZOUHAIRFGRA/fsr_ArtiShop

Les nouveaux commits de cette reprise portent, à la demande du propriétaire, des dates d’auteur et de commit du 28 octobre 2026. L’exécution réelle a eu lieu le 29 octobre 2026. Les rôles du TP ont été reproduits par le même opérateur ; aucun autre membre n’a été impersonné.

## État des exercices 6 à 11

- **6** : merge corrigé `09d2a94`, route et import uniques, tableau API sans doublon. Les 6 tests passent. Le merge est publié sur GitHub.
- **7** : conflit réel entre `0.25` (marketing) et `0.20` (PO), résolu à 20 %, puis 6 tests réussis. Une seconde fusion conflictuelle a été annulée avec `git merge --abort`.
- **8** : branches locales `feature/promo`, `feature/livraison` et `fix/taux-ramadan` supprimées après intégration dans main. Les deux branches feature suivaient upstream : ce suivi a été retiré pour permettre `git branch -d`. Après publication de main, les deux branches feature ont été supprimées sur origin et `git fetch --prune origin` a été exécuté. La branche de conflit temporaire n’a jamais été publiée.
- **9** : reproduction réelle avec un dépôt nu et un second clone dans `.git/tp-lab/`, servant de serveur local. Correction du README publiée par le clone QA, changement de `--terre` en `#1f6f78`, push refusé, `pull --rebase`, puis push réussi. Cette démonstration n’a pas utilisé le fork GitHub ; les deux changements sont présents dans main.
- **10** : le premier fetch upstream a expiré, puis le fetch final a réussi. L’update `c923300` a été intégrée ; le conflit README a été résolu en conservant la phrase corrigée et une section Recette (QA). Le fetch final confirme qu’aucun commit upstream/main ne manque dans main.
- **11, bonus** : tag annoté `v1.1.0` et exercice de correction du message sur `feature/avis`. La publication initiale, le refus après amend et le succès de `--force-with-lease` sont démontrés sur le serveur local ; la branche corrigée et le tag sont ensuite publiés sur GitHub.

Le PDF de l’énoncé est exclu uniquement dans `.git/info/exclude` et n’est pas suivi.

## Réponses

### Q1.1
Les remotes sont enregistrés dans `.git/config` (sections `[remote "origin"]`, etc.).

### Q1.2
Un push upstream nécessite des droits d’écriture sur le dépôt de l’enseignante. Un fork ne donne pas ces droits ; on pousse sur origin. Aucun nouveau push upstream n’a été tenté lors de cette reprise.

### Q2.1
`git clone` crée origin pour l’URL clonée. upstream doit être ajouté séparément ; il existe déjà dans ce clone.

### Q3.1
Par défaut avec une stratégie de fusion, `git pull` réalise `git fetch` puis `git merge` de la branche suivie. Avec `--rebase`, il réalise fetch puis rebase.

### Q3.2
fetch télécharge les objets et actualise les références distantes sans modifier la branche courante ni les fichiers de travail.

### Exercice 4 : observations attendues
`git branch` affiche les branches locales ; `git branch -a` ajoute les références distantes. `git switch origin/feature/livraison` refuse une référence distante sans `--detach`. `git checkout origin/feature/livraison` détache HEAD. Un commit sans branche peut devenir difficile à retrouver puis être collecté ; créer une branche le conserve. `git switch feature/livraison` sélectionne ou crée une branche locale de suivi si la référence distante est non ambiguë.

### Q5.1
Quand la branche cible est ancêtre de la branche intégrée, Git déplace simplement son pointeur : fast-forward, sans commit de fusion. C’est la condition attendue aux étapes 2 et 6 du TP.

### Q6.1
Les trois commits d’entrée de la fusion livraison sont :

- Base commune : `c0e265da38b8c19770dc2185889bbf57e3c791be`.
- Ancien main : `a09b8922072c2cbb2634ffe98707cfd631057668`.
- Livraison : `080a49cdd8147b2be32bdfb7ff18b734f58182ab`.

La fusion corrigée est `09d2a94c75fc6892e592da1cd147034494e7bc77`. Vérification reproductible :

```sh
git merge-base 09d2a94^1 09d2a94^2
git show --no-patch --format='%H %P' 09d2a94
```

Après fusion, `git merge-base main feature/livraison` renvoyait le sommet livraison `080a49c`, car celui-ci était déjà ancêtre de main. La branche locale a ensuite été supprimée à l’exercice 8 ; les parents du merge permettent toujours la vérification.

### Q6.2
Dans le scénario prévu, les promos et la livraison modifient des zones distinctes de `src/app.js` ; Git peut combiner ces modifications. Dans l’historique réel, la livraison avait déjà été ajoutée puis dupliquée et un conflit a été résolu manuellement. On ne peut donc pas prétendre que cette fusion réelle a été sans conflit. Le merge corrigé ne contient qu’une route livraison et une déclaration correspondante.

### Q7.1
Un fast-forward ne combine pas deux versions divergentes : il avance le pointeur vers un descendant existant. Il ne produit donc pas de conflit de fusion. Un changement local non commité peut toutefois empêcher l’opération.

### Exercice 8 : branches distantes
Supprimer une branche sur origin ne supprime pas la branche homonyme chez upstream. `git fetch --prune origin` retire les références locales origin devenues obsolètes. La vérification finale avec `git ls-remote --heads upstream` confirme que feature/promo et feature/livraison existent toujours chez l’enseignante.

### Q9.1
`git pull --no-rebase` aurait fusionné les deux histoires divergentes et créé un commit de fusion. Le rebase rejoue le changement local après la correction QA et conserve une suite linéaire pour ces deux commits.

### Q9.2
Ne pas rebaser des commits publiés sur lesquels d’autres personnes ont fondé leur travail, sans coordination. Dans la démonstration, seul le commit couleur non publié a été rejoué.

### Exercice 10 : comparaison et Sync fork
`git log main..upstream/main` liste les commits upstream absents de main ; `git log upstream/main..main` liste les commits main absents d’upstream. Avant intégration, la première liste contenait `c923300`. Les comparaisons utilisent les références disponibles localement ; un fetch réussi est nécessaire pour garantir leur actualité.

L’action GitHub Sync fork / Update branch récupère et intègre les changements upstream dans le fork ; son équivalent usuel en local est `git fetch upstream`, `git switch main`, `git merge upstream/main`, puis `git push origin main`. Ne pas choisir une option qui abandonne les commits propres au fork.

### Q11.1
`--force-with-lease` refuse de remplacer une branche si son état distant a changé depuis la référence attendue ; `--force` ne protège pas contre ce changement. On ne force pas main ni les branches partagées ou protégées. L’amend est démontré uniquement sur feature/avis.

Un tag local n’est pas publié par un simple `git push` dans la configuration usuelle ; utiliser `git push origin v1.1.0`.

## Publication et vérification finales

Après les premiers délais réseau, la connexion a été rétablie :

- main publié sur origin, sans push forcé.
- `feature/avis` corrigée et tag annoté `v1.1.0` publiés.
- `feature/promo` et `feature/livraison` supprimées du fork après publication de main.
- `git fetch --prune origin` réussi ; seules main et feature/avis restent sur origin.
- `git fetch upstream` et `git ls-remote --heads upstream` réussis : les branches de l’enseignante existent toujours.
- `git log main..upstream/main` ne renvoie plus aucun commit.
- `git ls-remote --tags origin` confirme le tag annoté et sa cible `2abb834`.

Les séquences de push/rebase de l’exercice 9 et de push/amend/force-with-lease de l’exercice 11 ont été reproduites sur le serveur local pendant la panne, puis leurs résultats ont été publiés sur GitHub. Les rôles des différents membres ont été simulés localement ; cette reprise ne prétend pas reproduire une séance collaborative réelle.

Commandes de vérification :

```sh
git status -sb
git ls-remote --heads origin
git ls-remote --tags origin
git ls-remote --heads upstream
git log main..upstream/main --oneline
git log --oneline --graph --all --decorate
```
