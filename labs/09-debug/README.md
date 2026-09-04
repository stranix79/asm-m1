# Labo 09 — Trois bugs, un débogueur

**Chapitre** : [10. Déboguer avec lldb](../../cours/10-lldb.md)

## Objectif
Trouver trois bugs classiques de l'assembleur ARM64 sur Mac en n'utilisant que lldb. Pas de solution avant d'avoir essayé.

## Consignes
`make` puis `./casse`. Le programme devrait afficher `Compte : 3` et sortir avec 0. À la place, il ne rend pas la main. Les trois bugs, dans l'ordre où tu vas les rencontrer :

1. **Ça tourne en rond.** `lldb ./casse`, `r`, laisse tourner deux secondes, puis `Ctrl-C`. `disassemble -p` : où est-on ? `register read x30` : d'où croit-on revenir ? Regarde ce que fait le `bl helper` dans `compte` à x30, et ce que `compte` a oublié de faire avant.
2. **Un crash à l'appel de printf.** Une fois le premier bug corrigé, `r` s'arrête sur `EXC_BAD_ACCESS` quelque part dans la libc. `bt` pour remonter à `_main`, puis `p/x $sp` : un pointeur de pile doit finir par 0. Indice : compte les octets réservés.
3. **Un affichage faux.** Le programme finit par tourner, mais affiche n'importe quoi à la place de 3. Relis le chapitre 9 : où doit aller l'argument variadique de `printf` sur Mac ?

Corrige `casse.s` bug après bug. La solution commentée est dans `solution/`, à ne lire qu'après.

## Pour aller plus loin
Provoque toi-même un `EXC_BAD_ACCESS` en lisant `[xzr]`, et un `SIGILL` avec `brk #0`. Apprends à les reconnaître.
