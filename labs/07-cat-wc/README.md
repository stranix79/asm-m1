# Labo 07 — cat et wc minimal, syscalls seulement

**Chapitre** : [8. Parler au noyau : les syscalls macOS](../../cours/08-syscalls-macos.md)

## Objectif
Lire stdin par blocs avec `read`, écrire avec `write`, compter des choses : le premier programme utile du cours.

## Consignes
1. `cat.s` est complet : `echo bonjour | ./cat`, puis `./cat < fichier`. Lis-le : la boucle `read` s'arrête quand x0 vaut 0 (fin de fichier).
2. Complète `wc_min.s` : compter les octets et les lignes (`\n`) de stdin, afficher `lignes octets`. `printf "a\nb\n" | make run` → `2 4`.
3. Vérifie sur un vrai fichier : `./wc_min < ../../README.md` contre `wc -lc ../../README.md`.
4. Que renvoie `read` si tu passes un descripteur invalide (`mov x0, #42`) ? Regarde x0 et le flag C dans lldb juste après le `svc`.

## Pour aller plus loin
Ajoute le compte des mots : un mot commence quand on passe d'un blanc (espace, tab, \n) à un non-blanc. C'est le cœur du projet final.
