# 3. Les registres

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 3 sur 12.* ← [2. Les outils, et ton premier programme](02-outils-premier-programme.md) · [Sommaire](../README.md) · [4. Les instructions de calcul](04-instructions-de-calcul.md) →

> 🧪 Labo associé : [`labs/02-registres`](../labs/02-registres/README.md)

### 3.1 Registres généraux

`x0` … `x30` : 31 registres de 64 bits. Chacun a une **vue 32 bits** nommée `w0` … `w30` (les 32 bits de poids faible). Écrire dans `w5` met à zéro les 32 bits hauts de `x5`.

```asm
mov x0, #5          // x0 = 5 (64 bits)
mov w0, #5          // idem, et bits 32-63 forcés à 0
add w1, w2, w3      // addition 32 bits
add x1, x2, x3      // addition 64 bits
```

Certains ont un rôle **par convention** (pas imposé par le processeur, mais tout le monde s'y tient, libc et noyau compris) :

| Registre | Rôle | Qui doit le préserver ? |
|---|---|---|
| `x0`–`x7` | arguments d'une fonction et valeur de retour (`x0`) | personne (l'appelé peut les écraser) |
| `x8` | adresse de résultat indirect (structures) | — |
| `x9`–`x15` | temporaires | personne |
| `x16`, `x17` | temporaires intra-procédure ; **x16 = numéro de syscall** sur macOS | — |
| `x18` | **réservé par Apple**, ne jamais y toucher | — |
| `x19`–`x28` | variables « durables » | **l'appelé** : s'il les utilise, il doit les sauvegarder et les restaurer |
| `x29` | *frame pointer* (fp) | l'appelé |
| `x30` | *link register* (lr) : adresse de retour posée par `bl` | l'appelé s'il rappelle quelqu'un |

Et les spéciaux :
- `sp` : pointeur de pile. **Doit toujours être un multiple de 16** au moment d'un accès ou d'un appel, sinon le noyau tue le programme.
- `pc` : compteur de programme (adresse de l'instruction courante). On ne l'écrit pas directement, on le change avec les branchements.
- `xzr` / `wzr` : le **registre zéro** : lit toujours 0, écrire dedans jette le résultat. Pratique : `mov x0, xzr`, ou `cmp x0, xzr`.
- `nzcv` : les 4 **flags** N (négatif), Z (zéro), C (retenue), V (débordement), mis à jour par `cmp` et les instructions en `s` (`adds`, `subs`…).

### 3.2 Voir les registres vivre (labo 02)

Le code de sortie d'un programme, c'est ce qu'il y a dans `x0` au moment de `exit`. C'est le moyen le plus simple d'observer un calcul sans savoir afficher : `./prog; echo $?`. Attention, seulement 8 bits : 256 devient 0.

Le vrai outil, c'est **lldb** : `lldb ./prog`, `b _start`, `r`, puis `si` (une instruction) et `register read`. L'antisèche est dans [`tools/lldb-antiseche.md`](../tools/lldb-antiseche.md).

**Labo 02** : un programme qui charge des valeurs dans plusieurs registres, les combine, et sort avec le résultat. À observer dans lldb instruction par instruction.

---

← [2. Les outils, et ton premier programme](02-outils-premier-programme.md) · [Sommaire](../README.md) · [4. Les instructions de calcul](04-instructions-de-calcul.md) →
