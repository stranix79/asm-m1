# 4. Les instructions de calcul

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 4 sur 12.* ← [3. Les registres](03-registres.md) · [Sommaire](../README.md) · [5. La mémoire : sections, données, tableaux](05-memoire.md) →

> 🧪 Labo associé : [`labs/03-arithmetique`](../labs/03-arithmetique/README.md)

### 4.1 Forme générale

Presque tout s'écrit `op destination, source1, source2`. La destination est toujours un registre.

```asm
add x0, x1, x2      // x0 = x1 + x2
add x0, x1, #10     // x0 = x1 + 10        (immédiat)
sub x0, x1, x2      // x0 = x1 - x2
mul x0, x1, x2      // x0 = x1 * x2
sdiv x0, x1, x2     // x0 = x1 / x2 (signé, tronqué vers 0)   — udiv pour non signé
msub x0, x1, x2, x3 // x0 = x3 - (x1 * x2)   → sert à faire un modulo : r = a - (a/b)*b
neg x0, x1          // x0 = -x1
and x0, x1, x2      // et bit à bit  (orr = ou, eor = ou exclusif, mvn = non)
lsl x0, x1, #3      // décalage à gauche (× 8)   — lsr à droite non signé, asr à droite signé
```

Il n'y a **pas d'instruction modulo** : `sdiv` puis `msub`. Il n'y a pas non plus de division qui donne le reste, ni de flags mis à jour par `mul`.

### 4.2 Les immédiats ont des règles

Une instruction fait 32 bits, la constante doit rentrer dedans. Donc :
- `add`/`sub` : immédiat de 0 à 4095 (12 bits), éventuellement décalé de 12 bits.
- `mov x0, #imm` : 16 bits, éventuellement décalés. Pour une grosse constante, l'assembleur découpe tout seul en `movz`/`movk`, ou tu utilises `ldr x0, =0x123456789` (l'assembleur range la constante dans une zone littérale et génère un `ldr` relatif au pc).
- `and`/`orr` : immédiats « bitmask » (motifs répétitifs). Si l'assembleur refuse, passe par un registre.

Règle pratique : si `as` dit *immediate out of range*, charge la valeur dans un registre d'abord.

### 4.3 Chargement et rangement mémoire

```asm
ldr x0, [x1]            // x0 = *(uint64_t*)x1
ldr x0, [x1, #8]        // x0 = *(x1 + 8)          (décalage immédiat)
ldr x0, [x1, x2]        // x0 = *(x1 + x2)         (décalage registre)
ldr x0, [x1, x2, lsl #3] // x0 = *(x1 + x2*8)      (indexation de tableau de 64 bits)
ldr w0, [x1]            // 32 bits
ldrb w0, [x1]           // 1 octet, zéro-étendu   (ldrsb : signé)
ldrh w0, [x1]           // 2 octets
str x0, [x1, #16]       // *(x1 + 16) = x0         (strb, strh : 1 et 2 octets)

ldr x0, [x1], #8        // post-incrément : x0 = *x1 ; puis x1 += 8   (parcourir un tableau)
ldr x0, [x1, #8]!       // pré-incrément : x1 += 8 ; puis x0 = *x1
stp x29, x30, [sp, #-16]!  // store pair : pousse deux registres sur la pile d'un coup
ldp x29, x30, [sp], #16    // load pair : les dépile
```

`stp`/`ldp` avec pré-/post-incrément, c'est le `push`/`pop` d'ARM64. Il n'y a pas d'instruction `push`.

**Labo 03** : arithmétique, modulo, immédiats hors limite, et un peu de mémoire.

---

← [3. Les registres](03-registres.md) · [Sommaire](../README.md) · [5. La mémoire : sections, données, tableaux](05-memoire.md) →
