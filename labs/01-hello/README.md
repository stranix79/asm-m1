# Labo 01 — Hello, ARM64

**Chapitre** : [2. Les outils, et ton premier programme](../../cours/02-outils-premier-programme.md)

## Objectif
Assembler, lier et lancer ton premier programme, puis le casser un peu pour comprendre chaque ligne.

## Consignes
1. `make run` : ça doit afficher `Hello, ARM64!` et sortir avec le code 0.
2. Ouvre `hello.s`. Change le message. Pense à la longueur dans `x2` (ou mieux : utilise `len = . - msg` comme dans la solution).
3. Mets volontairement une longueur trop grande (`#60`). Que se passe-t-il ? Pourquoi ce n'est pas un crash ?
4. Change le code de sortie en 7 et vérifie avec `echo $?`.
5. Remplace `mov x16, #4` par `mov x16, #1`. Qu'est-ce qui s'affiche ? Explique.
6. `make debug`, puis `si` plusieurs fois et `register read x0 x1 x2 x16` avant le premier `svc`.

## Pour aller plus loin
- `otool -tv hello` : le désassemblage de ce que tu viens de produire. Retrouve tes 8 instructions.
- `xxd hello | head` : c'est un Mach-O, le format d'exécutable d'Apple.
