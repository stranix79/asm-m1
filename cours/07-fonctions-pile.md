# 7. Fonctions, pile et convention d'appel

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 7 sur 12.* ← [6. Contrôle : comparer, sauter, boucler](06-controle-boucles.md) · [Sommaire](../README.md) · [8. Parler au noyau : les syscalls macOS](08-syscalls-macos.md) →

> 🧪 Labo associé : [`labs/06-fonctions`](../labs/06-fonctions/README.md)

C'est le chapitre le plus important du cours. Une fonction, en assembleur, ce n'est pas une construction du langage : c'est un **accord** entre celui qui appelle et celui qui est appelé, sur où mettre les paramètres, où rendre le résultat, et qui a le droit d'écraser quoi. Quand tu auras compris cet accord, tu comprendras la pile, les crashs « retour vers nulle part », et pourquoi `printf` plante quand `sp` n'est pas aligné.

---

## 7.1 Ce que fait vraiment un appel

Deux instructions et un registre :

- `bl fonction` (*branch with link*) : saute à l'étiquette `fonction`, **et** range dans `x30` l'adresse de l'instruction qui suit le `bl`. C'est l'adresse de retour.
- `ret` : saute à l'adresse contenue dans `x30`.

C'est tout ce que le processeur sait faire. Il ne sait pas ce qu'est un paramètre, une valeur de retour ou une variable locale. Tout ça, c'est la **convention d'appel**, un accord que tout le monde respecte pour pouvoir s'appeler : le noyau, la libc, le code produit par clang, et toi.

```asm
_start:
    mov x0, #5
    bl carre           // x30 = adresse de la ligne suivante ; saut vers carre
    // ici, x0 vaut 25
    ...
carre:
    mul x0, x0, x0     // x0 = x0 * x0
    ret                // retour à l'adresse dans x30
```

---

## 7.2 L'accord : qui met quoi où

Sur ARM64 la convention s'appelle **AAPCS64** (Apple y ajoute deux détails qu'on verra au chapitre 9). Elle tient en quatre règles.

**Règle 1 : les paramètres vont dans x0 à x7, le résultat revient dans x0.** Le premier paramètre dans x0, le deuxième dans x1, etc. Au-delà de huit, sur la pile (rare). Le résultat dans x0. C'est pour ça que `write` lisait x0, x1, x2 : le noyau suit la même convention.

**Règle 2 : x0 à x18 appartiennent à l'appelé.** Une fonction peut écraser x0-x18 sans prévenir. Donc si toi, l'appelant, tiens à une valeur dans x9, c'est **ton** problème : sauvegarde-la avant le `bl`, ou mets-la ailleurs. On dit que ces registres sont *caller-saved* (à la charge de l'appelant).

**Règle 3 : x19 à x28 appartiennent à l'appelant.** Une fonction qui veut utiliser x19 doit le **sauvegarder** en entrant et le **restaurer** avant de sortir. L'appelant peut compter dessus : ce qu'il y avait dans x19 avant le `bl` y est encore après. *Callee-saved* (à la charge de l'appelé). C'est là qu'on met les variables qui doivent survivre à des appels : le compteur de boucle du FizzBuzz est dans x19 pour cette raison.

**Règle 4 : x29, x30 et la pile.** x30 contient l'adresse de retour. Si ta fonction appelle elle-même une autre fonction avec `bl`, ce `bl` **écrase x30**. Ton propre `ret` partirait alors au mauvais endroit. Donc : toute fonction qui fait un `bl` doit sauvegarder x30 avant, et le restaurer après. Où ? Sur la pile.

---

## 7.3 La pile

La **pile** est une zone de mémoire réservée à chaque programme, pour ranger des choses temporaires : adresses de retour, registres à préserver, variables locales. Le registre `sp` pointe sur son sommet. Deux particularités :

- elle **descend** : réserver de la place, c'est faire `sp = sp - N` ; libérer, c'est `sp = sp + N` ;
- `sp` doit rester un **multiple de 16** en permanence. Un `sp` à 8 près fait planter le noyau et la libc. On réserve donc toujours par tranches de 16.

Il n'y a pas d'instruction `push`. On utilise `stp` (*store pair*) avec un pré-décrément, qui fait les deux d'un coup :

```asm
stp x29, x30, [sp, #-16]!   // sp = sp - 16 ; puis écrit x29 à [sp] et x30 à [sp+8]
```

et son miroir `ldp` (*load pair*) avec post-incrément pour dépiler :

```asm
ldp x29, x30, [sp], #16     // lit x29 et x30 depuis [sp] ; puis sp = sp + 16
```

Deux registres à la fois, 16 octets, alignement respecté : c'est fait pour.

---

## 7.4 Prologue et épilogue

Une fonction bien élevée commence par sauvegarder ce qu'elle va abîmer (le **prologue**) et finit par le restaurer (l'**épilogue**). Le cas de base, pour une fonction qui appelle quelqu'un :

```asm
ma_fonction:
    stp x29, x30, [sp, #-16]!   // prologue : sauve fp et lr
    mov x29, sp                 // x29 = nouveau "frame pointer" (voir plus bas)

    bl autre_fonction           // écrase x30, mais on l'a sauvé

    ldp x29, x30, [sp], #16     // épilogue : restaure
    ret                         // x30 est de nouveau l'adresse de retour de ma_fonction
```

`x29`, le *frame pointer*, pointe sur le début de la zone de pile de la fonction courante. Le processeur ne s'en sert pas. Le débogueur, si : c'est grâce à la chaîne des x29 sauvegardés qu'un `bt` (*backtrace*) peut afficher « fonction A appelée par B appelée par C ». Mets-le toujours, ça coûte une instruction.

Si la fonction utilise aussi x19 et x20, elle les sauve dans la même foulée, sur 16 octets de plus :

```asm
    stp x29, x30, [sp, #-32]!   // réserve 32 octets d'un coup
    mov x29, sp
    stp x19, x20, [sp, #16]     // x19 et x20 dans la moitié haute
    ...
    ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
```

Et une **fonction feuille** (qui n'appelle personne) et qui ne touche qu'à x0-x15 ? Elle n'a besoin de rien : pas de prologue, pas de pile, juste `ret`. `strlen` en est une. `itoa` du chapitre 5 aussi.

### Variables locales

Besoin de 24 octets pour des variables ? Après le prologue, `sub sp, sp, #32` (arrondi à 16), on adresse `[sp]`, `[sp, #8]`, `[sp, #16]`, et `add sp, sp, #32` avant l'épilogue. Tu en auras besoin pour `printf` au chapitre 9.

---

## 7.5 Exemple : strlen et une factorielle récursive

`strlen` : fonction feuille. Elle avance jusqu'à l'octet 0.

```asm
// x0 = adresse d'une chaîne .asciz → x0 = longueur
strlen:
    mov x1, x0              // x1 = curseur
1:  ldrb w2, [x1], #1       // lit un octet, avance
    cbnz w2, 1b             // pas le 0 final ? continue
    sub x0, x1, x0          // x1 a dépassé le 0 d'une case
    sub x0, x0, #1
    ret
```

`fact(n)` récursive : elle s'appelle elle-même avec `bl`, donc prologue obligatoire. Et elle a besoin de se souvenir de `n` après l'appel récursif, alors que l'appel écrase x0 : `n` va dans x19, qu'on sauve.

```asm
// x0 = n → x0 = n!
fact:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    stp x19, x20, [sp, #16]
    mov x19, x0             // n, à l'abri
    cmp x0, #1
    b.le 1f                 // n <= 1 → résultat 1
    sub x0, x0, #1
    bl fact                 // x0 = (n-1)!
    mul x0, x0, x19         // n * (n-1)!
    b 2f
1:  mov x0, #1
2:  ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
```

Chaque appel empile 32 octets : pour `fact(5)`, la pile descend de 160 octets, puis remonte. Dans lldb, pose `b fact`, lance, et à chaque arrêt fais `bt` et `p/x $sp` : tu verras la pile d'appels s'allonger et `sp` baisser de 32 en 32. C'est le labo 06.

Retire le `stp x29, x30` du prologue et relance : `fact` appelle `fact`, x30 pointe dans `fact`, chaque `ret` revient au milieu de `fact`… boucle ou crash. C'est le bug numéro un de l'assembleur, tu viens de le voir arriver.

---

## 7.6 À retenir

- `bl` saute et met l'adresse de retour dans x30 ; `ret` y retourne. Le reste est une convention.
- Paramètres x0-x7, résultat x0. x0-x18 : l'appelé les écrase. x19-x28 : l'appelé doit les rendre intacts.
- Une fonction qui fait un `bl` doit sauver x30 (et x29) : `stp x29, x30, [sp, #-16]!` en entrée, `ldp` en sortie. Une fonction feuille n'a besoin de rien.
- `sp` descend, par tranches de 16, et reste toujours multiple de 16.
- Variables à préserver à travers un appel → x19-x28, sauvés dans le prologue.

---

← [6. Contrôle : comparer, sauter, boucler](06-controle-boucles.md) · [Sommaire](../README.md) · [8. Parler au noyau : les syscalls macOS](08-syscalls-macos.md) →
