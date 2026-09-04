# 9. Mélanger C et assembleur

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 9 sur 12.* ← [8. Parler au noyau : les syscalls macOS](08-syscalls-macos.md) · [Sommaire](../README.md) · [10. Déboguer avec lldb](10-lldb.md) →

> 🧪 Labo associé : [`labs/08-c-interop`](../labs/08-c-interop/README.md)

Jusqu'ici tu as tout fait sans bibliothèque : pas de `printf`, pas de `malloc`. C'est formateur, mais dans la vraie vie l'assembleur vit à côté du C. Ce chapitre montre les deux sens : appeler la libc depuis l'assembleur, et appeler une fonction assembleur depuis un programme C. Avec, au passage, le piège numéro un de l'assembleur sur Mac.

---

## 9.1 Pourquoi ça marche : la même convention

La libc est écrite en C et compilée par clang, qui respecte la convention d'appel du chapitre 7. Donc `printf` attend son premier paramètre dans x0, écrase x0-x18, rend x0. Exactement comme tes fonctions. Un `bl _printf` est un `bl` comme un autre. Il n'y a rien de magique : la convention d'appel est le contrat qui permet à des morceaux de code écrits dans des langages différents de s'appeler.

Deux différences pratiques quand on utilise la libc :

- le point d'entrée n'est plus `_start` mais **`_main`** : c'est le démarreur C (ajouté par clang) qui prépare la libc puis appelle `_main`, comme pour un programme C. On ne lie plus avec `ld -e _start` mais avec `clang -o prog prog.s`, tout court ;
- `_main` est une fonction comme une autre : elle est appelée avec `bl`, elle doit donc **sauver x30** et faire `ret` avec son code de sortie dans w0 (au lieu du syscall exit).

---

## 9.2 Appeler printf, et le piège Apple

`puts` est simple : x0 = adresse d'une chaîne `.asciz`, `bl _puts`. `printf` a des **arguments variadiques** (le `...` du C), et c'est là qu'Apple diffère de tout le monde :

> **Sur macOS ARM64, les arguments variadiques passent par la pile, pas dans x1…x7.**

Sous Linux, `printf("%ld", 42)` mettrait 42 dans x1. Sur Mac, x1 est ignoré : `printf` va chercher 42 à `[sp]`. Si tu l'as mis dans x1, tu affiches ce qu'il y avait par hasard sur la pile. C'est la cause numéro un de « printf affiche n'importe quoi ».

Le programme complet, avec trois arguments variadiques :

```asm
.global _main
.align 2
.text
_main:
    stp x29, x30, [sp, #-16]!   // prologue : on va faire un bl
    mov x29, sp
    sub sp, sp, #32             // 3 arguments × 8 = 24 → arrondi à 32 (multiple de 16)

    adrp x9, name@PAGE
    add x9, x9, name@PAGEOFF
    str x9, [sp]                // 1er variadique (%s) → [sp]
    mov x9, #42
    str x9, [sp, #8]            // 2e (%ld) → [sp+8]
    mov x9, #180
    str x9, [sp, #16]           // 3e (%ld) → [sp+16]

    adrp x0, fmt@PAGE
    add x0, x0, fmt@PAGEOFF     // x0 = le format : lui est un paramètre normal, il reste dans x0
    bl _printf

    add sp, sp, #32             // libère la place
    mov w0, #0                  // return 0
    ldp x29, x30, [sp], #16
    ret

.data
fmt:  .asciz "%s a %ld ans et mesure %ld cm\n"
name: .asciz "Gilles"
```

À lire dans l'ordre : prologue, place sur la pile, les trois valeurs écrites à `[sp]`, `[sp+8]`, `[sp+16]` (dans l'ordre des `%`), le format dans x0, `bl`, nettoyage, retour. Compile avec `clang -o prog prog.s` et lance. Le labo 08 te fait ensuite mettre 42 dans x1 « à la Linux » pour voir le résultat.

Trois choses à ne pas oublier avec la libc :
1. le prologue `stp x29, x30` (sinon `ret` part n'importe où après `bl _printf`) ;
2. `sp` multiple de 16 au moment du `bl` (sinon crash dans la libc, souvent `EXC_BAD_ACCESS` loin de ton code) ;
3. les variadiques sur la pile, 8 octets chacun, dans l'ordre.

Les chaînes passées à la libc sont des chaînes C : `.asciz`, avec le zéro final.

---

## 9.3 Appeler de l'assembleur depuis le C

L'autre sens est encore plus simple. Une fonction `int64_t somme(const int64_t *tab, int64_t n)` : le C mettra `tab` dans x0 et `n` dans x1, et lira le résultat dans x0. Il suffit de l'écrire en respectant ça :

```asm
.global _somme          // visible depuis le C (avec l'underscore)
.align 2
.text
_somme:
    mov x2, #0          // accumulateur
    cbz x1, done
loop:
    ldr x3, [x0], #8    // élément courant, avance de 8
    add x2, x2, x3
    subs x1, x1, #1
    b.ne loop
done:
    mov x0, x2          // résultat
    ret
```

Côté C, une déclaration `extern int64_t somme(const int64_t *, int64_t);` et un appel normal. Compilation : `clang -o prog main.c somme.s`, clang assemble le `.s`, compile le `.c`, lie les deux. Fonction feuille : pas de prologue.

---

## 9.4 Apprendre en lisant clang

La meilleure façon d'apprendre l'assembleur, c'est de regarder ce que le compilateur produit :

```bash
clang -O0 -S -o - -x c - <<< 'long f(long a, long b){ long c = a + b; return c * 2; }'
clang -O2 -S -o - -x c - <<< 'long f(long a, long b){ long c = a + b; return c * 2; }'
```

À `-O0` (sans optimisation), clang range chaque variable sur la pile et la relit : verbeux mais tu reconnais chaque ligne du C. À `-O2`, il reste deux instructions : `add x0, x0, x1` et `lsl x0, x0, #1`. C'est le code qui tourne vraiment. Prends l'habitude de faire ça avec trois lignes de C dès que tu te demandes « comment on écrit ça en assembleur ».

---

## 9.5 À retenir

- La libc respecte la même convention : `bl _printf` est un appel comme un autre. Point d'entrée `_main`, lien avec `clang` seul.
- **Variadiques sur la pile** (`[sp]`, `[sp+8]`…), jamais dans x1+. Prologue et `sp` multiple de 16 obligatoires.
- Une fonction assembleur pour le C : `.global _nom`, paramètres x0-x7, résultat x0, `clang main.c fn.s`.
- `clang -S -o -` pour voir ce que le compilateur écrit.

---

← [8. Parler au noyau : les syscalls macOS](08-syscalls-macos.md) · [Sommaire](../README.md) · [10. Déboguer avec lldb](10-lldb.md) →
