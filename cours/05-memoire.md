# 5. La mémoire : sections, données, tableaux

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 5 sur 12.* ← [4. Les instructions de calcul](04-instructions-de-calcul.md) · [Sommaire](../README.md) · [6. Contrôle : comparer, sauter, boucler](06-controle-boucles.md) →

> 🧪 Labo associé : [`labs/04-tableaux-itoa`](../labs/04-tableaux-itoa/README.md)

### 5.1 Sections

- `.text` : le code (lecture seule, exécutable).
- `.data` : données initialisées (lecture/écriture).
- `.bss` : données non initialisées, à zéro au lancement, ne prennent pas de place dans le fichier : `.bss` puis `buffer: .space 1024`.
- Constantes en lecture seule : `.section __TEXT,__const` (syntaxe Mach-O ; `.rodata` de Linux n'existe pas tel quel).

### 5.2 Directives de données

```asm
.data
octet:   .byte 0x41            // 1 octet
mot16:   .hword 1000           // 2 octets  (.short)
mot32:   .word 100000          // 4 octets  (.int)
mot64:   .quad 0x1122334455667788   // 8 octets
tab:     .word 1, 2, 3, 4, 5   // tableau de 5 entiers 32 bits
chaine:  .ascii "abc"          // 3 octets, PAS de zéro final
chaine0: .asciz "abc"          // 4 octets, zéro final (comme en C)
.align 3                       // aligne ce qui suit sur 8 octets (2^3)
```

Pour une longueur de chaîne sans la compter à la main : `len = . - msg` juste après la chaîne (`.` = adresse courante), puis `mov x2, #len` (immédiat) ou `ldr x2, =len`.

### 5.3 Endianness et tailles

`ldr w0` sur `mot64` lit les 4 octets de poids faible (`0x55667788`), parce que little-endian. `ldrb` sur `mot32` lit `0xA0` (le premier octet de `100000 = 0x000186A0`). Fais-le dans lldb avec `x/8xb &mot64`, c'est le meilleur moyen de le fixer.

**Labo 04** : parcourir un tableau, sommer, trouver le max, et écrire un entier en ASCII (la boucle « diviser par 10 » de tout `itoa`).

---

← [4. Les instructions de calcul](04-instructions-de-calcul.md) · [Sommaire](../README.md) · [6. Contrôle : comparer, sauter, boucler](06-controle-boucles.md) →
