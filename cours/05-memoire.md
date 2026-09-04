# 5. La mémoire : sections, données, tableaux

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 5 sur 12.* ← [4. Les instructions de calcul](04-instructions-de-calcul.md) · [Sommaire](../README.md) · [6. Contrôle : comparer, sauter, boucler](06-controle-boucles.md) →

> 🧪 Labo associé : [`labs/04-tableaux-itoa`](../labs/04-tableaux-itoa/README.md)

Jusqu'ici, les données c'était une chaîne dans `.data`. Ce chapitre explique comment déclarer des nombres, des tableaux, des zones vides, comment ils sont rangés octet par octet, et comment on les parcourt. Il se termine par le premier vrai algorithme du cours : transformer un nombre en texte pour l'afficher.

---

## 5.1 Les trois zones

Un programme a trois zones de mémoire pour ses données et son code. Chacune s'ouvre par une directive, et tout ce qui suit va dedans jusqu'à la directive suivante.

| Directive | Contenu | Écrire dedans ? | Dans le fichier exécutable ? |
|---|---|---|---|
| `.text` | le code | non (protégé) | oui |
| `.data` | des données avec une valeur de départ | oui | oui (la valeur de départ y est stockée) |
| `.bss` | des données **sans** valeur de départ, mises à zéro au lancement | oui | non (juste « réserve-moi N octets ») |

`.bss` est fait pour les tampons : un espace de 4096 octets pour lire un fichier n'a pas besoin d'être stocké dans l'exécutable, il suffit de le réserver. `buf: .space 4096` dans `.bss`.

Pour des constantes en lecture seule (une table de valeurs qu'on ne modifie jamais), macOS a `.section __TEXT,__const`. Tu n'en auras pas besoin dans ce cours.

---

## 5.2 Déclarer des données

Une déclaration = une étiquette (le nom), une directive (la taille), une ou plusieurs valeurs.

```asm
.data
octet:   .byte 0x41                 // 1 octet  (0x41 = 65 = 'A')
mot16:   .hword 1000                // 2 octets
mot32:   .word 100000               // 4 octets
mot64:   .quad 0x1122334455667788   // 8 octets
tab:     .word 3, 17, 5, 42, 8      // 5 mots de 4 octets à la suite = un tableau
texte:   .ascii "abc"               // 3 octets, PAS de zéro à la fin
texte0:  .asciz "abc"               // 4 octets : a b c 0   (comme une chaîne C)
.bss
buf:     .space 24                  // 24 octets réservés, à zéro
```

Les noms des directives viennent de l'histoire d'ARM : `word` = 4 octets, `hword` = 2, `quad` = 8. (Attention si tu viens de x86 où `word` = 2 : ici non.)

Une chaîne `.ascii` n'a pas de zéro final. Pour l'afficher avec `write`, il faut connaître sa longueur. Plutôt que la compter, laisse l'assembleur le faire :

```asm
msg: .ascii "Hello, ARM64!\n"
len = . - msg        // "." est l'adresse courante ; adresse courante - adresse de msg = 14
```

Ensuite `mov x2, #len`. Tu ne te tromperas plus jamais de longueur.

### Alignement

Une donnée de 4 octets est plus rapide (et parfois obligatoire) si son adresse est un multiple de 4 ; 8 octets, multiple de 8. Après une chaîne de longueur quelconque, l'adresse suivante peut tomber n'importe où. `.align 3` force l'adresse suivante sur un multiple de 8 (2³). Prends l'habitude : `.align 3` avant un `.quad`, `.align 2` avant un `.word`. Les instructions NEON (chapitre 11) exigent 16 : `.align 4`.

---

## 5.3 Ce que ça donne octet par octet

La mémoire est une suite d'octets. Comment un nombre de 4 octets s'y range-t-il ? Sur ARM64 (comme sur x86), en **little-endian** : l'octet de poids **faible** en premier.

`mot32: .word 100000`. 100000 en hexadécimal = `0x000186A0`. En mémoire, à partir de l'adresse `mot32` :

```
adresse : mot32+0  mot32+1  mot32+2  mot32+3
contenu :   A0       86       01       00
```

Conséquences à connaître :
- `ldr w0, [x1]` (x1 = adresse de mot32) lit les 4 octets et reconstitue `0x000186A0` : tu récupères 100000, l'ordre est géré par le processeur.
- `ldrb w0, [x1]` lit **un** octet : tu obtiens `0xA0` = 160, pas 1.
- `ldr w0, [x1]` sur `mot64` (`0x1122334455667788`) donne `0x55667788` : les 4 octets de poids faible.

Dans lldb : `x/8xb &mot64` affiche `88 77 66 55 44 33 22 11`. Fais-le une fois, tu ne l'oublieras plus. Le labo 04 te le fait faire.

---

## 5.4 Parcourir un tableau

Un tableau, c'est des éléments de même taille à la suite. L'adresse de l'élément `i` = adresse de départ + `i × taille`. Deux façons de parcourir.

**Avec un index** (comme `tab[i]` en C) :

```asm
    adrp x19, tab@PAGE
    add x19, x19, tab@PAGEOFF    // x19 = adresse de tab
    mov x9, #2                   // i = 2
    ldr w10, [x19, x9, lsl #2]   // w10 = tab[2]  (adresse = x19 + 2*4)
```

`lsl #2` multiplie l'index par 4 parce que chaque `.word` fait 4 octets. Pour un tableau de `.quad`, ce serait `lsl #3`.

**Avec un pointeur qui avance**, en général plus court :

```asm
    mov x20, #5                  // 5 éléments
loop:
    ldr w9, [x19], #4            // lit tab[courant], puis x19 avance de 4
    add x22, x22, x9             // somme += élément
    subs x20, x20, #1            // compteur - 1, et pose les flags
    b.ne loop                    // tant que le compteur n'est pas à zéro (chapitre 6)
```

La forme `[x19], #4` (lire, puis avancer) est celle qu'on écrira le plus souvent. Note que le tableau n'a pas de « fin » en mémoire : c'est à toi de savoir combien d'éléments il a (ici, 5 dans x20). Une chaîne `.asciz` se termine par 0, on peut donc la parcourir jusqu'à trouver l'octet 0 : c'est comme ça que marche `strlen` (chapitre 7).

---

## 5.5 Transformer un nombre en texte : itoa

`write` affiche des octets, pas des nombres. Pour afficher 42, il faut produire les deux caractères `'4'` (valeur 52) et `'2'` (valeur 50). C'est l'algorithme *itoa* (*integer to ASCII*), que tu as sûrement déjà écrit dans un autre langage :

1. reste = n % 10 → dernier chiffre ; caractère = `'0'` + reste (le code de `'0'` est 48, celui de `'7'` est 55) ;
2. n = n / 10 ;
3. recommencer tant que n ≠ 0.

Les chiffres sortent **à l'envers** (d'abord les unités). L'astuce : écrire dans un tampon en partant de la fin et en reculant, le texte est alors dans le bon ordre. En ARM64, avec ce que tu connais déjà (`udiv`, `msub`, `strb`, un compteur) :

```asm
// entrée : x0 = nombre, x1 = adresse d'un tampon de 21 octets
// sortie : x0 = adresse du premier chiffre, x1 = longueur
itoa:
    add x2, x1, #20         // x2 = curseur, on part de la fin du tampon
    mov x3, #10
    mov x4, x2              // on garde la fin pour calculer la longueur
1:
    udiv x5, x0, x3         // x5 = n / 10
    msub x6, x5, x3, x0     // x6 = n - x5*10 = n % 10
    add x6, x6, #'0'        // chiffre → caractère ('0' est accepté comme immédiat : 48)
    sub x2, x2, #1          // recule d'une case
    strb w6, [x2]           // pose le caractère
    mov x0, x5              // n = n / 10
    cbnz x0, 1b             // si n ≠ 0, recommence (chapitre 6)
    mov x0, x2              // début du texte
    sub x1, x4, x2          // longueur = fin - début
    ret
```

Deux nouveautés de syntaxe : `#'0'` est le code ASCII du caractère `0`, l'assembleur le convertit ; `1:` est une **étiquette numérique**, locale, qu'on désigne par `1b` (le `1:` le plus proche en arrière, *back*) ou `1f` (en avant, *forward*). Pratique pour les petites boucles sans inventer un nom.

Le labo 04 te donne cette fonction et te fait afficher le maximum d'un tableau. Tu la réutiliseras dans tous les labos suivants : c'est ton `print(n)`.

---

## 5.6 À retenir

- `.text` code, `.data` données initialisées, `.bss` zones réservées à zéro (`.space N`).
- `.byte .hword .word .quad` = 1, 2, 4, 8 octets ; `.ascii` sans zéro final, `.asciz` avec ; `len = . - msg` pour la longueur.
- Little-endian : l'octet de poids faible en premier. `ldrb` sur un `.word` lit son octet faible.
- Élément `i` d'un tableau : `[base, i, lsl #2]` (4 octets) ; ou un pointeur qui avance : `[x, #4]` après lecture.
- itoa : diviser par 10, garder le reste, écrire à l'envers depuis la fin du tampon.

---

← [4. Les instructions de calcul](04-instructions-de-calcul.md) · [Sommaire](../README.md) · [6. Contrôle : comparer, sauter, boucler](06-controle-boucles.md) →
