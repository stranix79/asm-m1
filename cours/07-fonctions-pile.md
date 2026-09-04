# 7. Fonctions, pile et convention d'appel

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 7 sur 12.* ← [6. Contrôle : comparer, sauter, boucler](06-controle-boucles.md) · [Sommaire](../README.md) · [8. Parler au noyau : les syscalls macOS](08-syscalls-macos.md) →

> 🧪 Labo associé : [`labs/06-fonctions`](../labs/06-fonctions/README.md)

### 7.1 Le mécanisme

`bl fonction` (*branch with link*) : saute à `fonction` et met l'adresse de retour dans **x30** (lr). `ret` : saute à l'adresse dans x30. C'est tout ce que fait le processeur. Le reste est une convention : **AAPCS64** (Apple y ajoute deux nuances, chapitre 9).

- arguments dans `x0`…`x7`, résultat dans `x0` ;
- `x0`–`x18` : **caller-saved**, l'appelé fait ce qu'il veut avec, donc si l'appelant y tenait, c'était à lui de sauvegarder avant `bl` ;
- `x19`–`x30` : **callee-saved**, l'appelé doit les rendre intacts ;
- la pile croît vers les adresses basses, `sp` multiple de 16.

### 7.2 Prologue et épilogue

Une fonction « feuille » (qui n'appelle personne) qui ne touche qu'à x0-x15 n'a besoin de rien : elle calcule et fait `ret`. Dès qu'elle appelle quelqu'un, elle doit sauver x30 (sinon le `bl` interne l'écrase et son propre `ret` part n'importe où) :

```asm
ma_fonction:
    stp x29, x30, [sp, #-16]!   // sauve fp et lr, réserve 16 octets
    mov x29, sp                 // nouveau frame pointer (pour lldb et les backtraces)
    // ... si besoin de x19/x20 : stp x19, x20, [sp, #-16]! et ldp en miroir avant l'épilogue
    bl autre_fonction
    ldp x29, x30, [sp], #16     // restaure
    ret
```

Variables locales : `sub sp, sp, #32` après le prologue, on adresse `[sp]`, `[sp, #8]`…, et `add sp, sp, #32` avant l'épilogue. Toujours par multiples de 16.

### 7.3 Récursion

Rien de spécial : chaque appel empile son x30 et ses locales. Une factorielle récursive fait un bon exercice pour voir la pile grandir dans lldb (`bt`).

**Labo 06** : `strlen`, `max` d'un tableau et une factorielle récursive, appelées depuis `_start`.

---

← [6. Contrôle : comparer, sauter, boucler](06-controle-boucles.md) · [Sommaire](../README.md) · [8. Parler au noyau : les syscalls macOS](08-syscalls-macos.md) →
