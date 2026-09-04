# asm-m1 — apprendre l'assembleur ARM64 sur un Mac Apple Silicon

```
$ whoami
stranix · le renard qui aime savoir ce qui se passe sous le capot

$ cat asm-m1/README.md
```

Tu codes déjà. En C, en Python, en PHP, peu importe. Tu as peut-être croisé de l'assembleur pendant tes études, il y a longtemps, et il n'en reste qu'un vague souvenir de registres et de `mov`. Et tu as un Mac M1, M2 ou M3 sur le bureau.

Ce dépôt est un cours **qui part de zéro** pour programmer en assembleur **ARM64 natif sur macOS**, avec les outils déjà installés sur ta machine : `as`, `ld`, `clang`, `lldb`. Pas de machine virtuelle, pas d'émulateur, pas de x86 d'un autre âge. Le processeur qui est dans ton Mac, et rien d'autre entre toi et lui.

Le but n'est pas d'écrire des applications en assembleur. Le but est de **comprendre** ce que font vraiment un registre, une pile, un appel de fonction, un `printf`, un syscall, et de ne plus jamais regarder un débogueur ou un rapport de crash comme du bruit.

## Comment ça marche

Douze chapitres courts, chacun suivi d'un labo. Le labo donne un squelette à compléter, un `Makefile` qui assemble, lie et lance, et une solution commentée. Tout a été assemblé et exécuté sur un MacBook M1 sous macOS avec Xcode 26.

| Chapitre | Labo |
|---|---|
| [0. Pourquoi faire ça](cours/00-pourquoi.md) | — |
| [1. Ta machine : Apple Silicon = ARM64](cours/01-ta-machine-arm64.md) | — |
| [2. Les outils, et ton premier programme](cours/02-outils-premier-programme.md) | [01-hello](labs/01-hello/README.md) |
| [3. Les registres](cours/03-registres.md) | [02-registres](labs/02-registres/README.md) |
| [4. Les instructions de calcul](cours/04-instructions-de-calcul.md) | [03-arithmetique](labs/03-arithmetique/README.md) |
| [5. La mémoire : sections, données, tableaux](cours/05-memoire.md) | [04-tableaux-itoa](labs/04-tableaux-itoa/README.md) |
| [6. Contrôle : comparer, sauter, boucler](cours/06-controle-boucles.md) | [05-fizzbuzz](labs/05-fizzbuzz/README.md) |
| [7. Fonctions, pile et convention d'appel](cours/07-fonctions-pile.md) | [06-fonctions](labs/06-fonctions/README.md) |
| [8. Parler au noyau : les syscalls macOS](cours/08-syscalls-macos.md) | [07-cat-wc](labs/07-cat-wc/README.md) |
| [9. Mélanger C et assembleur](cours/09-c-et-assembleur.md) | [08-c-interop](labs/08-c-interop/README.md) |
| [10. Déboguer avec lldb](cours/10-lldb.md) | [09-debug](labs/09-debug/README.md) |
| [11. SIMD/NEON, juste pour voir](cours/11-neon.md) | [10-neon](labs/10-neon/README.md) |
| [12. Projet final et pour aller plus loin](cours/12-projet-et-suite.md) | [11-projet-wc](labs/11-projet-wc/README.md) |

Antisèche du débogueur : [tools/lldb-antiseche.md](tools/lldb-antiseche.md).

## Démarrer en deux minutes

```bash
xcode-select --install          # si ce n'est pas déjà fait (Command Line Tools)
git clone https://github.com/stranix79/asm-m1.git
cd asm-m1/labs/01-hello
make run                        # assemble, lie, lance : Hello, ARM64!
make solution                   # la version corrigée
make debug                      # lldb, arrêté sur la première instruction
```

## Ce que tu sauras faire à la fin

- écrire, assembler, lier et lancer un programme ARM64 natif ;
- manipuler registres, mémoire, pile, boucles, fonctions ;
- appeler le noyau macOS directement (syscalls) et la libc (`printf`, avec le piège Apple des arguments variadiques) ;
- mélanger C et assembleur dans les deux sens, et lire ce que clang produit ;
- déboguer instruction par instruction avec lldb ;
- écrire un petit `wc` en assembleur pur, sans une ligne de C.

## Pourquoi en français, pourquoi sur Mac

Parce que presque tout ce qui existe sur l'assembleur ARM64 est en anglais, vise Linux ou un Raspberry Pi, et que les quelques différences macOS (le `_` devant les symboles, `x16` pour les syscalls, `-lSystem`, les variadiques sur la pile) font perdre des heures à qui débarque. Ici, tout est écrit pour la machine que tu as devant toi.

Licence MIT. Le cours est vivant : une erreur, une question, une idée de labo, ouvre une issue. On en parle aussi sur [stranix.net](https://stranix.net).

```
$ ls /ventures
code79.com     consulting/
sygnet.app     saas/
stranix.net    blog/          ← tu es ici
```
