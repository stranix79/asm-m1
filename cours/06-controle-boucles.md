# 6. Contrôle : comparer, sauter, boucler

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 6 sur 12.* ← [5. La mémoire : sections, données, tableaux](05-memoire.md) · [Sommaire](../README.md) · [7. Fonctions, pile et convention d'appel](07-fonctions-pile.md) →

> 🧪 Labo associé : [`labs/05-fizzbuzz`](../labs/05-fizzbuzz/README.md)

En assembleur il n'y a ni `if`, ni `while`, ni `for`. Il y a une seule chose : **sauter** à une autre instruction, éventuellement à condition. Tout le reste se construit avec ça. Ce chapitre montre comment, et pourquoi c'est moins pénible qu'il n'y paraît.

---

## 6.1 Sauter

Le processeur exécute les instructions dans l'ordre, en avançant `pc` de 4 à chaque fois. Un **branchement** (*branch*) change `pc` : la prochaine instruction exécutée est celle de l'étiquette visée.

```asm
    b suite             // saut inconditionnel : va à l'étiquette "suite"
    mov x0, #1          // jamais exécuté
suite:
    mov x0, #2
```

`b` seul, c'est le `goto`. Utile pour sortir d'une boucle ou sauter un bloc. Toute la structure d'un programme assembleur repose sur des étiquettes et des `b`.

---

## 6.2 Comparer, puis sauter si

Un `if` se fait en deux temps : une **comparaison** qui pose les flags (les 4 bits N, Z, C, V du chapitre 3), puis un **saut conditionnel** qui lit ces flags.

```asm
    cmp x0, x1          // calcule x0 - x1, jette le résultat, garde les flags
    b.eq egaux          // saute si le résultat était zéro, donc si x0 == x1
    ...                 // ici : x0 != x1
egaux:
```

`cmp` compare un registre à un registre ou à un immédiat (`cmp x0, #10`). Les suffixes de `b.` disent la condition :

| Suffixe | Saute si | Se lit |
|---|---|---|
| `eq` / `ne` | égal / différent | equal / not equal |
| `lt` / `le` / `gt` / `ge` | <, ≤, >, ≥ en **signé** | less than, less or equal, greater than, greater or equal |
| `lo` / `ls` / `hi` / `hs` | <, ≤, >, ≥ en **non signé** | lower, lower or same, higher, higher or same |
| `mi` / `pl` | résultat négatif / positif ou nul | minus / plus |

Signé ou non signé : les mêmes bits, deux lectures. `cmp x0, x1` avec x0 = -1 (tous les bits à 1) et x1 = 5 : en signé, -1 < 5 donc `b.lt` saute ; en non signé, `0xFFFF…` est un immense nombre, donc `b.hi` saute. Pour des adresses ou des compteurs, utilise le non signé ; pour des valeurs qui peuvent être négatives, le signé.

Un `if … else` complet :

```asm
    cmp x0, #10
    b.ge grand          // si x0 >= 10, aller à "grand"
    mov x1, #0          // branche "petit"
    b fin
grand:
    mov x1, #1          // branche "grand"
fin:
```

Oui, c'est plus verbeux qu'en C. C'est exactement ce que le compilateur écrit à ta place.

### Les raccourcis

Deux cas si fréquents qu'ils ont leur instruction, sans `cmp` :

```asm
    cbz x0, zero        // compare and branch if zero : saute si x0 == 0
    cbnz x0, nonzero    // saute si x0 != 0
    tbz x0, #3, bit3off // test bit and branch : saute si le bit 3 de x0 est à 0
```

`cbz`/`cbnz` servent pour « tant que ce n'est pas fini », « si la chaîne est terminée » (octet nul), « si le compteur est à zéro ».

---

## 6.3 Les boucles

Une boucle = une étiquette au début, un test, un saut en arrière. Voici `for (i = 0; i < n; i++) { ... }` :

```asm
    mov x9, #0              // i = 0
loop:
    cmp x9, x10             // i < n ?   (x10 contient n)
    b.ge done               // sinon, sortir
    // ... le corps de la boucle ...
    add x9, x9, #1          // i++
    b loop                  // et on recommence
done:
```

Lis-la à voix haute : « i vaut 0. Boucle : si i ≥ n, fini. Corps. i + 1. Retour à boucle. » C'est un `for`, écrit avec les mains.

Version à rebours, plus courte, quand tu sais combien de tours faire :

```asm
    mov x9, #5              // 5 tours
loop:
    // ... corps ...
    subs x9, x9, #1         // x9 = x9 - 1, ET pose les flags (le s de subs)
    b.ne loop               // tant que x9 != 0
```

`subs` (et `adds`, `ands`…) : la version avec `s` fait le calcul **et** met les flags, ce qui évite un `cmp` juste après. Le compteur descend jusqu'à zéro et la boucle s'arrête. Tu l'as vue dans le parcours de tableau du chapitre 5.

Un `while` est la même chose sans le compteur : test au début, saut à la fin. Un `do … while` : corps d'abord, test à la fin.

---

## 6.4 Choisir sans sauter

Un saut a un coût caché : le processeur devine à l'avance quelle branche sera prise, et se trompe parfois. Pour les petits `if` qui choisissent juste une valeur, ARM64 propose de ne pas sauter du tout :

```asm
    cmp x9, x21
    csel x21, x9, x21, gt   // conditional select : x21 = (x9 > x21) ? x9 : x21
```

`csel dest, si_vrai, si_faux, condition` : un `? :` en une instruction. C'est le « garde le maximum » du labo 04, sans branchement. Cousins utiles : `cset w0, eq` (w0 = 1 si la condition est vraie, sinon 0) et `cinc x20, x20, eq` (x20 + 1 si vrai, sinon inchangé), pratique pour compter des occurrences dans une boucle.

---

## 6.5 Exemple : FizzBuzz

Tout le chapitre dans un programme que tu connais : pour i de 1 à 15, afficher FizzBuzz si multiple de 15, Fizz si multiple de 3, Buzz si multiple de 5, sinon le nombre. Le squelette :

```asm
    mov x19, #1                 // i (dans x19 : il doit survivre aux appels, chapitre 7)
loop:
    mov x0, x19
    mov x1, #15
    bl mod                      // x0 = i % 15   (une petite fonction udiv/msub)
    cbz x0, is_fizzbuzz
    mov x0, x19
    mov x1, #3
    bl mod
    cbz x0, is_fizz
    mov x0, x19
    mov x1, #5
    bl mod
    cbz x0, is_buzz
    // ... sinon : itoa + print du nombre ...
    b next
is_fizzbuzz:
    // ... print "FizzBuzz\n" ...
    b next
is_fizz:
    // ...
    b next
is_buzz:
    // ...
next:
    add x19, x19, #1
    cmp x19, #15
    b.le loop
```

Chaque `cbz … / b next` est une branche du `if`. L'ordre des tests compte (15 avant 3 et 5), exactement comme en C. Le labo 05 te fait compléter ce programme et vérifier la sortie contre un FizzBuzz shell.

---

## 6.6 À retenir

- `b etiquette` : saut. Tout `if`, `while`, `for` est fait de sauts.
- `cmp a, b` pose les flags ; `b.eq b.ne b.lt b.le b.gt b.ge` (signé), `b.lo b.ls b.hi b.hs` (non signé) sautent selon.
- `cbz` / `cbnz` : saute si zéro / non zéro, sans `cmp`.
- Boucle : étiquette, test, corps, incrément, `b` en arrière. À rebours : `subs` + `b.ne`.
- `csel`, `cset`, `cinc` : choisir sans sauter.

---

← [5. La mémoire : sections, données, tableaux](05-memoire.md) · [Sommaire](../README.md) · [7. Fonctions, pile et convention d'appel](07-fonctions-pile.md) →
