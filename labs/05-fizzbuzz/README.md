# Labo 05 — FizzBuzz sans printf

**Chapitre** : [6. Contrôle : comparer, sauter, boucler](../../cours/06-controle-boucles.md)

## Objectif
Boucles, comparaisons et branchements conditionnels, avec seulement le syscall `write` pour afficher.

## Consignes
1. Complète `fizzbuzz.s` : pour i de 1 à 15, afficher `FizzBuzz` si i % 15 == 0, `Fizz` si i % 3 == 0, `Buzz` si i % 5 == 0, sinon le nombre. Un résultat par ligne.
2. `make run` doit donner exactement la sortie de `for i in $(seq 1 15); do ...` en shell. Compare avec `make run | diff - <(seq 1 15 | sed 's/^3$/Fizz/;s/^5$/Buzz/;s/^6$/Fizz/;s/^9$/Fizz/;s/^10$/Buzz/;s/^12$/Fizz/;s/^15$/FizzBuzz/')`.
3. Réécris le test `% 15` avec `msub` et un seul `cbz`.
4. Bonus : remplace la cascade de `b.eq` par une table de sauts (`adr x9, table` + `ldr` + `br`).

## Pour aller plus loin
`clang -O1 -S` sur un FizzBuzz en C : compare le code produit pour les modulos (multiplication par l'inverse plutôt que division).
