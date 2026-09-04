# 12. Projet final et pour aller plus loin

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 12 sur 12.* ← [11. SIMD/NEON, juste pour voir](11-neon.md) · [Sommaire](../README.md)

> 🧪 Labo associé : [`labs/11-projet-wc`](../labs/11-projet-wc/README.md)

Tu as tout ce qu'il faut. Le projet final assemble les pièces dans un programme réel, puis quelques pistes pour continuer.

---

## 12.1 Le projet : wc en assembleur pur

Réécrire `wc`, l'utilitaire Unix qui compte les lignes, les mots et les octets d'un fichier. Sans une ligne de C, sans la libc : seulement les syscalls.

```
$ ./wc_asm README.md
69 603 4289
$ printf "a b\nc\n" | ./wc_asm
2 3 6
```

Ce qu'il mobilise, chapitre par chapitre :

- **les arguments de la ligne de commande** : sur macOS, `dyld` (le chargeur de programmes) appelle ton `_start` **comme une fonction** : `x0` = argc (le nombre d'arguments), `x1` = argv (l'adresse d'un tableau de pointeurs de 8 octets vers les chaînes). `argv[1]` = `ldr x0, [x1, #8]`. Sous Linux, ce serait `[sp]` = argc : encore une différence à connaître si tu lis un tutoriel ;
- **open / read / close / write / exit** (chapitre 8), avec le test d'erreur `b.cs` si le fichier n'existe pas ;
- **une boucle de lecture** par blocs de 4096 octets (chapitre 8), et une **machine à deux états** pour les mots : « je suis dans un mot » ou « je suis dans du blanc », un mot commence à chaque passage blanc → non-blanc (chapitre 6) ;
- **des fonctions** avec prologue pour l'affichage (chapitre 7) et **itoa** (chapitre 5) ;
- **lldb** quand ça ne compte pas juste (chapitre 10).

Le labo 11 fournit un squelette où `open`, `argv`, lignes et octets sont écrits, et où il manque les mots. Puis `make test` compare avec le `wc` du système. Quand les trois nombres tombent juste sur trois fichiers, tu as fini le cours.

---

## 12.2 Et après

Quelques directions, par ordre d'utilité :

1. **Relire du code compilé.** Prends un petit programme C que tu connais, `clang -O2 -S -o - prog.c`, et lis. Tout ce que tu vois maintenant a un nom. C'est l'usage quotidien de ce que tu as appris : comprendre ce que fait vraiment le compilateur, lire un rapport de crash, un profil, un `objdump`.
2. **Les flottants.** `d0`-`d31`, `fadd`, `fmul`, `scvtf` (entier → flottant), et un `printf("%f")` où le `double` variadique va lui aussi sur la pile.
3. **Un `strlen` plus malin.** Lire 8 octets à la fois et détecter le zéro avec des opérations sur les bits, puis NEON : c'est ce que fait la libc, et un bon exercice de mesure avec `clock()`.
4. **Le code auto-modifiant, les tables de sauts, le `switch`** : `adr` + `ldr` + `br`.
5. **Écrire une fonction en assembleur dans un vrai projet**, là où ça a un sens : une boucle interne mesurée comme critique, après avoir vérifié que clang ne fait pas déjà mieux.

Références qui valent le coup :

- *Arm Architecture Reference Manual for A-profile* : la bible, pour chercher une instruction précise. Énorme, mais l'index suffit.
- *Procedure Call Standard for the Arm 64-bit Architecture (AAPCS64)* : la convention d'appel, une trentaine de pages.
- Apple, *Writing ARM64 code for Apple platforms* : les nuances Apple (x18, variadiques, alignement), la page qui manque à tous les tutoriels.
- `man 2 intro` et `sys/syscall.h` du SDK : les syscalls et leurs numéros.
- Le désassemblage de clang, encore et toujours.

Bon voyage. Le premier `Hello, ARM64!` qui sort, c'était déjà 80 % du chemin.

---

← [11. SIMD/NEON, juste pour voir](11-neon.md) · [Sommaire](../README.md)
