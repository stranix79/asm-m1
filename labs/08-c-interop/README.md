# Labo 08 — C et assembleur dans les deux sens

**Chapitre** : [9. Mélanger C et assembleur](../../cours/09-c-et-assembleur.md)

## Objectif
Appeler `printf` depuis l'assembleur (et tomber sur le piège Apple des arguments variadiques), puis appeler une fonction assembleur depuis un programme C.

## Consignes
1. `make printf` puis `./printf` : `printf.s` définit `_main`, clang ajoute le démarreur C et la libc. Lis le passage des trois arguments variadiques **sur la pile**.
2. Modifie-le pour mettre 42 dans `x1` au lieu de `[sp, #8]`, comme on ferait sous Linux. Lance. Voilà le bug n°1 de l'assembleur sur Mac.
3. Complète `somme.s` : `int64_t somme(const int64_t *tab, int64_t n)`. `make somme` puis `./somme` → `somme = 150`.
4. `clang -O2 -S -o - somme.c` : compare la fonction `main` produite par clang avec ce que tu aurais écrit. Cherche l'appel à `_somme` et comment les arguments sont préparés.
5. `clang -O0 -S -o - -x c - <<< 'long f(long a, long b){ long c = a + b; return c * 2; }'` puis la même chose en `-O2`. Compte les instructions.

## Pour aller plus loin
Écris `strlen` en assembleur et appelle-la depuis C à la place de celle de la libc. Compare les vitesses sur une longue chaîne avec `clock()`.
