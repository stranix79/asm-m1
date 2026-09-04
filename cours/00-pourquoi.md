# 0. Pourquoi faire ça

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 0 sur 12.* [Sommaire](../README.md) · [1. Ta machine : Apple Silicon = ARM64](01-ta-machine-arm64.md) →

L'assembleur, c'est le langage que le processeur exécute vraiment. Tout ce que tu écris en C, Python ou PHP finit par là. L'apprendre, ce n'est pas pour écrire des applications avec, c'est pour **comprendre** : ce qu'est un registre, ce que coûte un appel de fonction, pourquoi la pile est alignée sur 16 octets, ce que fait vraiment `printf`, ce que te montre un débogueur ou une trace de crash. Après ce cours, un `lldb`, un dump de registres, un `objdump` ou un rapport de crash macOS ne seront plus du bruit.

Ce que tu sauras faire à la fin :
- écrire, assembler, lier et lancer un programme ARM64 natif sur macOS ;
- manipuler registres, mémoire, pile, boucles, fonctions ;
- parler au noyau macOS directement (syscalls) et à la libc (`printf`) ;
- mélanger C et assembleur dans les deux sens ;
- déboguer instruction par instruction avec lldb ;
- lire du code désassemblé produit par clang.

Le cours suit un fil : **chapitre → labo**. Lis le chapitre, fais le labo (il y a un squelette à compléter et une solution commentée), passe au suivant. Compte une à deux heures par chapitre.

---

[Sommaire](../README.md) · [1. Ta machine : Apple Silicon = ARM64](01-ta-machine-arm64.md) →
