# 11. SIMD/NEON, juste pour voir

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 11 sur 12.* ← [10. Déboguer avec lldb](10-lldb.md) · [Sommaire](../README.md) · [12. Projet final et pour aller plus loin](12-projet-et-suite.md) →

> 🧪 Labo associé : [`labs/10-neon`](../labs/10-neon/README.md)

ARM64 a 32 registres vectoriels de 128 bits, `v0`…`v31`, vus comme `v0.4s` (4 × 32 bits), `v0.2d` (2 × 64), `v0.16b` (16 octets)… Une instruction traite tout le vecteur :

```asm
ld1 {v0.4s}, [x0]       // charge 4 entiers 32 bits depuis x0
ld1 {v1.4s}, [x1]
add v2.4s, v0.4s, v1.4s // 4 additions en une instruction
st1 {v2.4s}, [x2]       // range le résultat
```

C'est ce que fait clang à -O2 sur une boucle simple (auto-vectorisation). Les 64 bits bas de `v0` s'appellent `d0`, les 32 bas `s0` : ce sont aussi les registres flottants (`fadd d0, d1, d2`).

**Labo 10** : additionner deux tableaux avec NEON, et comparer avec la version scalaire.

---

← [10. Déboguer avec lldb](10-lldb.md) · [Sommaire](../README.md) · [12. Projet final et pour aller plus loin](12-projet-et-suite.md) →
