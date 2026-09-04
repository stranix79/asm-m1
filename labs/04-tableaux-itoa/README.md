# Labo 04 — Tableaux, somme, max, et afficher un nombre

**Chapitre** : [5. La mémoire : sections, données, tableaux](../../cours/05-memoire.md)

## Objectif
Parcourir un tableau en mémoire, et convertir un entier en texte pour l'afficher (la boucle « diviser par 10 » de tout `itoa`).

## Consignes
1. Le tableau `tab` contient 5 entiers 32 bits. Complète la boucle de somme dans `tableaux.s` : parcours avec `ldr w?, [x?], #4` (post-incrément). Le code de sortie doit être 75.
2. Ajoute la recherche du maximum (42) dans x21.
3. La fonction `itoa` est fournie : elle transforme x0 en chiffres ASCII dans un tampon. Utilise-la pour afficher le max, suivi d'un retour à la ligne. `make run` → `42` puis `code de sortie : 75`.
4. Dans lldb : `x/5xw &tab` (5 mots de 32 bits en hexa) puis `x/20xb &tab` : retrouve le little-endian.
5. Remplace `.word` par `.quad` dans le tableau et adapte la boucle (`ldr x?` et `#8`).

## Pour aller plus loin
Écris la version signée d'itoa (un `-` devant si négatif : `tbnz x0, #63, negatif`).
