# Labo 03 — Arithmétique, modulo, immédiats

**Chapitre** : [4. Les instructions de calcul](../../cours/04-instructions-de-calcul.md)

## Objectif
Faire des calculs sans instruction modulo, et cohabiter avec les limites des immédiats.

## Consignes
1. Complète `arith.s` pour calculer `r = (7 * 6 + 3) % 7` avec `mul`, `add`, `udiv` et `msub`. `make run` → code de sortie 3.
2. Ajoute `mov x9, #100000`. L'assembleur accepte ou refuse ? Remplace par `ldr x9, =100000` et regarde le désassemblage (`otool -tv arith`) : où est passée la constante ?
3. Calcule 100000 / 1000 dans x10 et vérifie dans lldb (`register read -f d x10`).
4. Décale : `lsl x11, x9, #3` (× 8) et `lsr x12, x9, #1` (÷ 2). Vérifie.
5. Bonus : `and x13, x9, #0xff` marche ; `and x13, x9, #0x12345` est refusé. Pourquoi ? (chapitre 4.2, immédiats bitmask). Comment faire quand même ?

## Pour aller plus loin
`clang -O2 -S -o - -x c - <<< 'int f(int a){return a % 7;}'` : regarde comment clang évite la division pour un modulo par constante.
