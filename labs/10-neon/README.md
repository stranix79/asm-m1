# Labo 10 — Quatre additions en une instruction (NEON)

**Chapitre** : [11. SIMD/NEON, juste pour voir](../../cours/11-neon.md)

## Objectif
Additionner deux tableaux de 4 entiers avec les registres vectoriels, et voir la différence avec la version scalaire.

## Consignes
1. `neon.s` : la version scalaire (boucle de 4 `ldr`/`add`/`str`) est écrite. Complète la version NEON : `ld1 {v0.4s}, [x0]`, `ld1 {v1.4s}, [x1]`, `add v2.4s, v0.4s, v1.4s`, `st1 {v2.4s}, [x2]`.
2. `make run` → `11 22 33 44`.
3. Dans lldb : `register read v0 v1 v2` après le `add` vectoriel. Lis les 4 lanes.
4. Remplace `.4s` par `.16b` : 16 additions d'octets. Que deviennent les résultats ? Pourquoi ?
5. `clang -O2 -S -o - -x c - <<< 'void add4(int *c, const int *a, const int *b){ for(int i=0;i<4;i++) c[i]=a[i]+b[i]; }'` : clang vectorise tout seul, retrouve les mêmes instructions.

## Pour aller plus loin
Multiplie deux vecteurs de flottants (`fmul v2.4s`) et affiche-les… ce qui demande une conversion flottant → texte : c'est une bonne raison d'appeler `printf("%f")` (attention : un `double` variadique va aussi sur la pile).
