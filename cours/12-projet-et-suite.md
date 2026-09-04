# 12. Projet final et pour aller plus loin

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 12 sur 12.* ← [11. SIMD/NEON, juste pour voir](11-neon.md) · [Sommaire](../README.md)

> 🧪 Labo associé : [`labs/11-projet-wc`](../labs/11-projet-wc/README.md)

**Labo 11, projet** : un `wc` complet en assembleur pur (syscalls seulement) : lit stdin ou un fichier passé en argument, compte lignes, mots, octets, affiche les trois nombres. Tout ce que tu as vu y passe : syscalls, boucles, fonctions, conversion entier → texte, arguments de la ligne de commande (sur macOS, dyld appelle `_start` comme une fonction : `x0` = argc, `x1` = argv ; sous Linux ce serait `[sp]` = argc).

Références qui valent le coup :
- *Arm Architecture Reference Manual for A-profile* : la bible, pour chercher une instruction précise.
- *Procedure Call Standard for the Arm 64-bit Architecture (AAPCS64)* : la convention d'appel.
- Apple, *Writing ARM64 code for Apple platforms* : les nuances Apple (x18, variadiques, alignement).
- `man 2 intro` et `sys/syscall.h` : les syscalls et leurs numéros.
- Le désassemblage de clang, encore et toujours : `clang -O1 -S -o - fichier.c`.

Bon voyage. Le premier `Hello, ARM64!` qui sort, c'est déjà 80 % du chemin.

---

← [11. SIMD/NEON, juste pour voir](11-neon.md) · [Sommaire](../README.md)
