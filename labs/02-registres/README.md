# Labo 02 — Voir les registres vivre

**Chapitre** : [3. Les registres](../../cours/03-registres.md)

## Objectif
Observer des registres 64 et 32 bits dans lldb, et utiliser le code de sortie comme « affichage ».

## Consignes
1. Complète `registres.s` : x1 = 10, x2 = 32, x0 = x1 + x2, puis exit avec x0. `make run` doit finir par `code de sortie : 42`.
2. `make debug`, puis `si` instruction par instruction avec `register read x0 x1 x2 x3` après chacune.
3. Regarde ce que fait `mov x3, #-1` puis `mov w3, #5` : lis x3 après chaque instruction. Pourquoi x3 vaut 5 et pas `0xffffffff00000005` ?
4. Mets 300 dans x0 avant exit. Que dit `echo $?` ? Explique (indice : 300 = 0x12C).
5. Essaie `mov x18, #1` : ça assemble, ça tourne… et pourtant tu ne dois jamais le faire. Relis le tableau du chapitre 3.

## Pour aller plus loin
`register read cpsr` après `subs x4, x1, x2` : quel bit est levé ? Refais-le avec `subs x4, x2, x1`.
