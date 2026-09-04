# 1. Ta machine : Apple Silicon = ARM64

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 1 sur 12.* ← [0. Pourquoi faire ça](00-pourquoi.md) · [Sommaire](../README.md) · [2. Les outils, et ton premier programme](02-outils-premier-programme.md) →

Le M1 (M2, M3…) est un processeur **ARM**, architecture **AArch64** (on dit aussi ARM64, ou arm64 chez Apple). Ce n'est pas du x86 : si tes souvenirs d'études sont du 8086 ou du x86-32, presque rien du vocabulaire ne survit (pas de `eax`, pas de `push`/`pop` classiques, pas de `int 0x80`). Bonne nouvelle : ARM64 est **plus simple et plus régulier** que x86.

Trois idées à garder dès maintenant :

1. **RISC** : instructions de taille fixe (4 octets chacune), peu de modes d'adressage, et une règle d'or : **on ne calcule que dans les registres**. La mémoire se lit avec `ldr` et s'écrit avec `str`, point. Pas de `add [mem], 5`.
2. **31 registres généraux de 64 bits** (`x0` à `x30`) plus quelques registres spéciaux. En x86 on manquait de registres, ici on en a trop.
3. **Little-endian** : un entier 32 bits `0x11223344` est stocké en mémoire `44 33 22 11`. Comme x86.

Apple a sa propre variante de la convention d'appel ARM64 (quelques différences, on les verra au chapitre 9) et son propre format d'exécutable (**Mach-O**, pas ELF). Ça change deux ou trois lignes, pas l'essentiel.

---

← [0. Pourquoi faire ça](00-pourquoi.md) · [Sommaire](../README.md) · [2. Les outils, et ton premier programme](02-outils-premier-programme.md) →
