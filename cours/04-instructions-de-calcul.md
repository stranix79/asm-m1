# 4. Les instructions de calcul

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 4 sur 12.* ← [3. Les registres](03-registres.md) · [Sommaire](../README.md) · [5. La mémoire : sections, données, tableaux](05-memoire.md) →

> 🧪 Labo associé : [`labs/03-arithmetique`](../labs/03-arithmetique/README.md)

Tu sais mettre un nombre dans un registre. Ce chapitre montre comment calculer avec, comment lire et écrire la mémoire, et une contrainte qui surprend tout le monde au début : les constantes ne rentrent pas toujours dans une instruction.

---

## 4.1 La forme générale : destination, puis sources

Presque toutes les instructions de calcul s'écrivent de la même façon :

```
opération  destination, source1, source2
```

Le résultat va dans la **destination**, toujours un registre, écrite en premier. Les sources ne sont pas modifiées. C'est l'inverse de l'habitude `a = b + c` en lecture, mais c'est le même sens : `add x0, x1, x2` se lit « x0 reçoit x1 plus x2 ».

```asm
add x0, x1, x2      // x0 = x1 + x2
add x0, x1, #10     // x0 = x1 + 10        la seconde source peut être une constante
sub x0, x1, x2      // x0 = x1 - x2
sub x0, x0, #1      // x0 = x0 - 1         la destination peut être une des sources
mul x0, x1, x2      // x0 = x1 * x2
neg x0, x1          // x0 = -x1
```

Une constante écrite avec `#` s'appelle un **immédiat** : elle fait partie de l'instruction elle-même. On y revient en 4.3.

### Division et modulo

```asm
sdiv x0, x1, x2     // x0 = x1 / x2, division entière SIGNÉE (tronquée vers zéro : -7/2 = -3)
udiv x0, x1, x2     // idem, NON signée (les registres sont vus comme positifs)
```

Il n'y a **pas d'instruction modulo**. Pour obtenir un reste, on divise, puis on retranche : `reste = a - (a / b) * b`. ARM64 a une instruction qui fait « multiplier puis soustraire » d'un coup :

```asm
udiv x5, x4, x1         // x5 = x4 / x1
msub x0, x5, x1, x4     // x0 = x4 - (x5 * x1)   → le reste
```

`msub d, a, b, c` calcule `c - (a * b)`. Lis-la comme « multiply-subtract ». C'est le motif qu'on écrira pour chaque `%`, garde-le sous la main.

Diviser par zéro ne plante pas : le résultat est 0. C'est à toi de vérifier avant si ça compte.

### Logique et décalages

```asm
and x0, x1, x2      // et bit à bit
orr x0, x1, x2      // ou
eor x0, x1, x2      // ou exclusif
mvn x0, x1          // non (inverse tous les bits)
lsl x0, x1, #3      // décalage à gauche de 3 bits = multiplier par 8
lsr x0, x1, #1      // décalage à droite = diviser par 2 (non signé)
asr x0, x1, #1      // décalage à droite qui garde le signe (pour les négatifs)
```

Les décalages sont la façon rapide de multiplier ou diviser par une puissance de 2, et de manipuler des bits un par un. Un compilateur remplace toujours `x * 8` par `lsl x, #3`.

---

## 4.2 Un exemple complet

Calculer `(7 * 6 + 3) % 7` et le rendre en code de sortie :

```asm
    mov x1, #7
    mov x2, #6
    mov x3, #3
    mul x4, x1, x2          // x4 = 42
    add x4, x4, x3          // x4 = 45
    udiv x5, x4, x1         // x5 = 45 / 7 = 6
    msub x0, x5, x1, x4     // x0 = 45 - 6*7 = 3
    mov x16, #1
    svc #0x80               // exit(3)
```

Dans lldb, avance avec `si` et lis `x4`, puis `x5`, puis `x0`. Tu dois voir 42, 45, 6, 3 apparaître dans cet ordre. C'est le labo 03.

---

## 4.3 Les immédiats ne rentrent pas toujours

Une instruction fait 32 bits, et il faut y caser le code de l'opération et les numéros de registres. Il reste peu de place pour la constante. Conséquence : **toutes les valeurs ne sont pas acceptées** comme immédiat.

- `add` et `sub` acceptent de 0 à 4095.
- `mov` accepte n'importe quel nombre de 16 bits (0 à 65535), éventuellement « décalé » (65536, 131072…). Pour les autres, l'assembleur se débrouille souvent en générant deux instructions (`movz` puis `movk`), mais pas toujours.
- `and`, `orr`, `eor` n'acceptent que des motifs de bits réguliers (`0xff`, `0xff00`, `0x0f0f0f0f`…), pas une valeur quelconque.

Quand ça ne passe pas, `as` affiche `immediate out of range` ou `invalid operand`. La solution universelle :

```asm
ldr x9, =100000     // "charge dans x9 la constante 100000"
```

Avec un `=`, tu demandes à l'assembleur de ranger la constante dans un coin du programme (une « zone littérale ») et de générer un `ldr` qui va la lire. Ça marche pour n'importe quelle valeur de 64 bits. Ensuite tu calcules avec le registre :

```asm
ldr x14, =0x12345
and x13, x9, x14    // à la place de : and x13, x9, #0x12345 (refusé)
```

Règle pratique : **si l'assembleur refuse ta constante, charge-la dans un registre avec `ldr xN, =valeur`, et utilise le registre.** Ne cherche pas plus loin.

---

## 4.4 Lire et écrire la mémoire

Rappel du chapitre 2 : on ne calcule que dans les registres. La mémoire ne sert qu'à ranger et reprendre. Deux instructions : `ldr` (*load register*, lire) et `str` (*store register*, écrire). Entre crochets, on écrit **où** en mémoire.

```asm
ldr x0, [x1]            // x0 = les 8 octets qui sont à l'adresse contenue dans x1
str x0, [x1]            // écrit les 8 octets de x0 à l'adresse contenue dans x1
```

Les crochets se lisent « à l'adresse ». `x1` doit donc contenir une adresse (obtenue par `adrp`/`add`, ou par calcul). On peut ajouter un décalage :

```asm
ldr x0, [x1, #8]        // à l'adresse x1 + 8   (le 2e élément d'un tableau de 64 bits)
ldr x0, [x1, x2]        // à l'adresse x1 + x2
ldr x0, [x1, x2, lsl #3]  // à l'adresse x1 + x2*8  : "l'élément numéro x2" d'un tableau de 8 octets
```

### Les tailles

`ldr x0` lit 8 octets. Pour moins :

```asm
ldr  w0, [x1]           // 4 octets (un int)
ldrh w0, [x1]           // 2 octets (h = half)
ldrb w0, [x1]           // 1 octet  (b = byte) : un caractère, par exemple
strb w0, [x1]           // écrit 1 octet
```

Les petites lectures vont dans un `w` et complètent avec des zéros. `ldrsb`/`ldrsh` complètent avec le signe (pour des nombres négatifs sur 8 ou 16 bits).

### Avancer en lisant

Pour parcourir un tableau ou une chaîne, on veut lire **et** avancer le pointeur. ARM64 le fait en une instruction :

```asm
ldr x0, [x1], #8        // x0 = *x1 ; PUIS x1 = x1 + 8      (post-incrément)
ldrb w0, [x1], #1       // lit un caractère et avance d'un
ldr x0, [x1, #8]!       // x1 = x1 + 8 ; PUIS x0 = *x1      (pré-incrément, notez le !)
```

Et pour deux registres d'un coup, ce qui sert surtout avec la pile (chapitre 7) :

```asm
stp x29, x30, [sp, #-16]!   // sp = sp - 16, puis écrit x29 à [sp] et x30 à [sp+8]
ldp x29, x30, [sp], #16     // lit x29 et x30, puis sp = sp + 16
```

`stp`/`ldp` avec ces décalages, c'est le `push`/`pop` d'ARM64. Il n'y a pas d'instruction `push`.

---

## 4.5 À retenir

- `op dest, src1, src2` : le résultat va dans le premier registre.
- `add sub mul sdiv udiv`, logique `and orr eor mvn`, décalages `lsl lsr asr`. Pas de modulo : `udiv` puis `msub`.
- Un immédiat qui ne passe pas → `ldr xN, =valeur` puis le registre.
- Mémoire : `ldr` lit, `str` écrit, `[x1, #8]` = « à l'adresse x1 + 8 ». `b`/`h`/`w` pour 1, 2, 4 octets.
- `[x1], #8` lit puis avance : la boucle de parcours de tout le cours.

---

← [3. Les registres](03-registres.md) · [Sommaire](../README.md) · [5. La mémoire : sections, données, tableaux](05-memoire.md) →
