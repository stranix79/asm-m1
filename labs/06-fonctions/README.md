# Labo 06 — Fonctions, pile et récursion

**Chapitre** : [7. Fonctions, pile et convention d'appel](../../cours/07-fonctions-pile.md)

## Objectif
Écrire des fonctions qui respectent la convention d'appel, dont une récursive, et voir la pile dans lldb.

## Consignes
1. Complète `strlen` : x0 = adresse d'une chaîne terminée par 0, retourne la longueur dans x0. Fonction feuille, sans prologue.
2. Complète `fact` : factorielle récursive. Elle appelle `bl fact`, donc elle **doit** sauver x29/x30 (prologue `stp`), et garder n dans un registre callee-saved (x19) qu'elle sauve aussi.
3. `_start` affiche `fact(5)` (120) et sort avec `strlen("Bonjour")` (7). `make run` → `120` puis `code de sortie : 7`.
4. `make debug`, `b fact`, `r`, puis `c` cinq fois avec `bt` à chaque arrêt : regarde la pile d'appels grandir, et `p/x $sp` descendre de 32 en 32.
5. Retire le `stp x29, x30` du prologue de `fact` : que se passe-t-il ? Pourquoi ?

## Pour aller plus loin
Écris `max(tab, n)` et appelle-la depuis `_start` avec le tableau du labo 04.
