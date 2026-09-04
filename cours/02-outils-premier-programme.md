# 2. Les outils, et ton premier programme

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 2 sur 12.* ← [1. Ta machine : Apple Silicon = ARM64](01-ta-machine-arm64.md) · [Sommaire](../README.md) · [3. Les registres](03-registres.md) →

> 🧪 Labo associé : [`labs/01-hello`](../labs/01-hello/README.md)

Tout est dans Xcode ou les *Command Line Tools* (`xcode-select --install`). Tu as déjà tout :

| Outil | Rôle |
|---|---|
| `as` | l'assembleur : `.s` → `.o` (fichier objet) |
| `ld` | l'éditeur de liens : `.o` → exécutable Mach-O |
| `clang` | fait les deux en une commande, et sert pour mélanger avec du C |
| `lldb` | le débogueur |
| `otool -tv` / `objdump -d` | désassembler un binaire |

### 2.1 Hello, ARM64 (labo 01)

```asm
.global _start          // rend le symbole _start visible pour ld
.align 2                // aligne le code sur 4 octets (2^2)
.text                   // section code

_start:
    mov x0, #1              // x0 = 1 = descripteur stdout
    adrp x1, msg@PAGE       // x1 = adresse de la page qui contient msg
    add x1, x1, msg@PAGEOFF //      + le décalage dans la page → adresse de msg
    mov x2, #14             // x2 = nombre d'octets à écrire
    mov x16, #4             // x16 = numéro du syscall write (4 sur macOS)
    svc #0x80               // appel au noyau

    mov x0, #0              // code de sortie 0
    mov x16, #1             // syscall exit (1)
    svc #0x80

.data                   // section données
msg: .ascii "Hello, ARM64!\n"
```

Assembler, lier, lancer :

```bash
as -o hello.o hello.s
ld -o hello hello.o -lSystem -syslibroot $(xcrun -sdk macosx --show-sdk-path) -e _start -arch arm64
./hello
```

Ou en une commande : `clang -o hello hello.s -nostartfiles -e _start`.

Ce qu'il faut retenir de ces lignes :
- `_start` avec un **underscore** : sur macOS, tous les symboles C/asm portent un `_` devant. `main` en C s'appelle `_main` en assembleur.
- `-lSystem` même sans libc : macOS refuse de lancer un exécutable qui n'est pas lié à `libSystem` (c'est `dyld` qui l'exige). Sous Linux, ce ne serait pas nécessaire.
- `-e _start` : on dit à `ld` quel est le point d'entrée. Sans ça, il cherche `_main` et attend le démarreur C.
- `adrp` + `add … @PAGEOFF` : la façon ARM64 de charger l'**adresse** d'une donnée (les adresses font 64 bits, une instruction fait 32 bits : impossible de la mettre dans une seule instruction, donc on la construit en deux). `adr` seul marche pour une cible dans la même section et à moins de 1 Mo, mais Mach-O refuse souvent le saut de section : prends l'habitude d'`adrp`/`add`.
- `svc #0x80` : *supervisor call*, c'est le passage au noyau. Le numéro du service est dans **x16** (particularité Darwin ; sous Linux c'est `x8` et `svc #0`).

**Labo 01** : écrire, assembler, lancer, puis modifier le message et la longueur, faire volontairement une longueur fausse pour voir ce qui se passe.

---

← [1. Ta machine : Apple Silicon = ARM64](01-ta-machine-arm64.md) · [Sommaire](../README.md) · [3. Les registres](03-registres.md) →
