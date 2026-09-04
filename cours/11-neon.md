# 11. SIMD/NEON, juste pour voir

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 11 sur 12.* ← [10. Déboguer avec lldb](10-lldb.md) · [Sommaire](../README.md) · [12. Projet final et pour aller plus loin](12-projet-et-suite.md) →

> 🧪 Labo associé : [`labs/10-neon`](../labs/10-neon/README.md)

Un chapitre court, pour ouvrir une porte. Tout ce que tu as fait jusqu'ici traite un nombre à la fois. Le processeur sait aussi en traiter plusieurs d'un coup : c'est le SIMD (*Single Instruction, Multiple Data*), qu'ARM appelle **NEON**. C'est ce qui fait tourner le son, la vidéo, le chiffrement et une bonne partie des boucles que clang optimise.

---

## 11.1 Des registres plus larges

À côté des x0-x30, le processeur a **32 registres vectoriels de 128 bits**, `v0` à `v31`. On les regarde à travers une « grille » qui dit comment découper les 128 bits :

| Écriture | Découpage | Ce qu'on y met |
|---|---|---|
| `v0.16b` | 16 cases de 8 bits | des octets, des caractères |
| `v0.8h` | 8 cases de 16 bits | |
| `v0.4s` | 4 cases de 32 bits | des `int` ou des `float` |
| `v0.2d` | 2 cases de 64 bits | des `long` ou des `double` |

Chaque case s'appelle une **lane** (une voie). Une instruction vectorielle fait la même opération sur toutes les voies en même temps.

Les mêmes registres servent aux **flottants** : `d0` désigne les 64 bits bas de `v0` (un `double`), `s0` les 32 bits bas (un `float`). `fadd d0, d1, d2` additionne deux doubles. Les flottants sont donc hors des x0-x30 : un paramètre `double` se passe dans d0, pas dans x0.

---

## 11.2 Quatre additions en une instruction

Additionner deux tableaux de 4 entiers. La version scalaire du chapitre 5, c'est une boucle de 4 tours avec `ldr`, `add`, `str`. La version NEON :

```asm
    ld1 {v0.4s}, [x0]           // charge 4 entiers 32 bits depuis l'adresse x0 dans v0
    ld1 {v1.4s}, [x1]           // idem dans v1
    add v2.4s, v0.4s, v1.4s     // 4 additions, une instruction : chaque voie de v2 = v0 + v1
    st1 {v2.4s}, [x2]           // range les 4 résultats à l'adresse x2
```

`ld1` / `st1` chargent et rangent un vecteur entier. Pour que ça marche bien, les tableaux doivent être alignés sur 16 octets en mémoire : `.align 4` avant leur déclaration.

Avec `v0.16b` à la place de `v0.4s`, les mêmes 128 bits sont vus comme 16 octets, et `add` fait 16 additions d'un octet chacune, avec débordement à 255. C'est le labo 10 : mêmes données, autre grille, autre résultat.

---

## 11.3 Ce que fait clang

```bash
clang -O2 -S -o - -x c - <<< 'void add4(int *c, const int *a, const int *b){ for (int i = 0; i < 4; i++) c[i] = a[i] + b[i]; }'
```

Tu retrouves `ldr q0` / `ldr q1` (charger 128 bits), `add v0.4s, v1.4s, v0.4s`, `str q0`. Le compilateur a **vectorisé** la boucle tout seul. C'est pour ça qu'une boucle simple en C est souvent plus rapide que l'assembleur qu'on écrirait à la main : clang connaît NEON mieux que nous.

Aller plus loin avec NEON demande un vrai livre. L'important ici : savoir que ça existe, reconnaître `v0.4s` dans un désassemblage, et savoir que les flottants vivent dans `d0`-`d31`.

---

## 11.4 À retenir

- 32 registres `v0`-`v31` de 128 bits, découpés en voies : `.16b`, `.8h`, `.4s`, `.2d`.
- `ld1`, `add vN.4s`, `st1` : une opération sur toutes les voies à la fois. Données alignées sur 16.
- `d0`/`s0` = les flottants, dans les mêmes registres.
- clang vectorise seul les boucles simples à `-O2`.

---

← [10. Déboguer avec lldb](10-lldb.md) · [Sommaire](../README.md) · [12. Projet final et pour aller plus loin](12-projet-et-suite.md) →
