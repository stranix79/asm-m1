# 9. Mélanger C et assembleur

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 9 sur 12.* ← [8. Parler au noyau : les syscalls macOS](08-syscalls-macos.md) · [Sommaire](../README.md) · [10. Déboguer avec lldb](10-lldb.md) →

> 🧪 Labo associé : [`labs/08-c-interop`](../labs/08-c-interop/README.md)

### 9.1 Appeler la libc depuis l'assembleur

Il suffit de définir `_main` au lieu de `_start`, de laisser clang lier normalement, et d'appeler `_puts`, `_printf`… avec `bl`. **Deux règles Apple** à connaître absolument :

1. **Les arguments variadiques passent par la pile**, pas dans x1…x7. `printf("%ld", 42)` : x0 = format, et 42 doit être **écrit sur la pile** à `[sp]`. C'est la grande différence avec Linux ARM64, et la cause n°1 de « printf affiche n'importe quoi » sur Mac.
2. Toujours un prologue `stp x29, x30` avant le `bl`, et `sp` aligné sur 16.

```asm
.global _main
.align 2
_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #16
    mov x0, #42
    str x0, [sp]                // l'argument variadique va sur la pile
    adrp x0, fmt@PAGE
    add x0, x0, fmt@PAGEOFF
    bl _printf
    add sp, sp, #16
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret
.data
fmt: .asciz "La réponse est %ld\n"
```

`clang -o prog prog.s` et c'est tout : clang ajoute le démarreur C et la libc.

### 9.2 Appeler de l'assembleur depuis C

Une fonction `int64_t addition(int64_t a, int64_t b)` en assembleur :

```asm
.global _addition
.align 2
_addition:
    add x0, x0, x1
    ret
```

Côté C : `extern int64_t addition(int64_t, int64_t);`, puis `clang -o prog main.c addition.s`. Les arguments arrivent dans x0 et x1 parce que la convention est la même des deux côtés.

### 9.3 Lire ce que clang produit

`clang -O2 -S -o - fichier.c` affiche l'assembleur généré. C'est **la** méthode pour apprendre : écris trois lignes de C, regarde ce que le compilateur en fait, compare avec ce que tu aurais écrit. À -O0 c'est verbeux mais lisible ; à -O2 c'est ce qui tourne vraiment.

**Labo 08** : printf avec plusieurs arguments, une fonction asm appelée depuis C, et une lecture du désassemblage de clang.

---

← [8. Parler au noyau : les syscalls macOS](08-syscalls-macos.md) · [Sommaire](../README.md) · [10. Déboguer avec lldb](10-lldb.md) →
