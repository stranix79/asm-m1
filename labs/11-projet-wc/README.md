# Labo 11 — Projet : wc en assembleur pur

**Chapitre** : [12. Projet final et pour aller plus loin](../../cours/12-projet-et-suite.md)

## Objectif
Un `wc` complet, sans une ligne de C ni de libc : lignes, mots, octets, depuis stdin ou un fichier passé en argument.

## Cahier des charges
- `./wc_asm < fichier` et `./wc_asm fichier` donnent le même résultat que `wc fichier` (les trois nombres, séparés par un espace, puis un retour à la ligne).
- Un mot = passage d'un caractère blanc (espace, tab, `\n`, `\r`) à un non-blanc.
- Lecture par blocs de 4096 octets.
- Si le fichier n'existe pas : message `wc_asm: impossible d'ouvrir` sur stderr et code de sortie 1.

## Ce que ça mobilise
- les arguments de la ligne de commande : sur macOS, dyld appelle ton `_start` **comme une fonction C** : `x0` = argc, `x1` = argv (tableau de pointeurs de 8 octets), `x2` = envp. Donc `argv[1]` = `ldr x0, [x1, #8]`. (Sous Linux, ce serait `[sp]` = argc : encore une différence à connaître) ;
- `open` (syscall 5 : x0 = chemin, x1 = 0 pour lecture seule, x2 = 0), `read`, `write`, `close`, `exit` ;
- une machine à états à deux états (dans un mot / hors mot) ;
- `itoa` et l'affichage.

## Étapes conseillées
1. Pars de `wc_min` (labo 07), ajoute les mots.
2. Ajoute la lecture de `argc` / `argv[1]` et `open`.
3. Gère l'erreur d'ouverture (flag C après `svc`, ou x0 > 0xfff… en pratique teste `b.cs`).
4. `make test` compare avec le `wc` du système sur trois fichiers. Un écart d'un mot peut apparaître sur un fichier qui contient des espaces Unicode (insécable, etc.) : `wc` les connaît, notre machine à états ne regarde que espace, tab, `\n` et `\r`. C'est voulu, et c'est un bon exercice de l'étendre.

Le squelette `wc_asm.s` contient les morceaux déjà vus ; la solution commentée est dans `solution/`.
