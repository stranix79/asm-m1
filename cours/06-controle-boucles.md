# 6. Contrôle : comparer, sauter, boucler

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 6 sur 12.* ← [5. La mémoire : sections, données, tableaux](05-memoire.md) · [Sommaire](../README.md) · [7. Fonctions, pile et convention d'appel](07-fonctions-pile.md) →

> 🧪 Labo associé : [`labs/05-fizzbuzz`](../labs/05-fizzbuzz/README.md)

### 6.1 Comparer

`cmp x0, x1` fait `x0 - x1` sans garder le résultat, et pose les flags. Ensuite un **branchement conditionnel** :

| Instruction | Saute si | Type |
|---|---|---|
| `b.eq` / `b.ne` | égal / différent | — |
| `b.lt` `b.le` `b.gt` `b.ge` | <, ≤, >, ≥ | **signé** |
| `b.lo` `b.ls` `b.hi` `b.hs` | <, ≤, >, ≥ | **non signé** |
| `b.mi` / `b.pl` | négatif / positif ou nul | — |

Raccourcis très utilisés : `cbz x0, label` (saute si x0 == 0), `cbnz` (si ≠ 0), `tbz x0, #3, label` (saute si le bit 3 est à 0).

Et sans saut du tout : `csel x0, x1, x2, gt` (x0 = gt ? x1 : x2), `cset w0, eq` (w0 = 1 si égal sinon 0), `cinc`, `csneg`… Le processeur adore : pas de branchement, pas de mauvaise prédiction.

### 6.2 Boucles

Il n'y a rien d'autre que `cmp` + `b.xx`. Une boucle `for (i = 0; i < n; i++)` :

```asm
    mov x9, #0              // i
loop:
    cmp x9, x10             // i < n ?
    b.ge done
    // ... corps ...
    add x9, x9, #1
    b loop
done:
```

Variante en comptant à rebours, souvent plus courte : `subs x9, x9, #1` (soustrait ET pose les flags) puis `b.ne loop`.

### 6.3 Sauts

`b label` : saut inconditionnel. `br x0` : saut à l'adresse dans x0 (tables de sauts, `switch`). On verra `bl` au chapitre suivant.

**Labo 05** : FizzBuzz sans printf (on écrit avec le syscall), puis une recherche dans un tableau.

---

← [5. La mémoire : sections, données, tableaux](05-memoire.md) · [Sommaire](../README.md) · [7. Fonctions, pile et convention d'appel](07-fonctions-pile.md) →
