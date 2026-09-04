# 3. Les registres

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 3 sur 12.* ← [2. Les outils, et ton premier programme](02-outils-premier-programme.md) · [Sommaire](../README.md) · [4. Les instructions de calcul](04-instructions-de-calcul.md) →

> 🧪 Labo associé : [`labs/02-registres`](../labs/02-registres/README.md)

Au chapitre 2, tu as mis des nombres dans x0, x1, x2 et x16 sans savoir ce qui les distingue. Ce chapitre répond à trois questions : combien y a-t-il de registres, qu'est-ce qu'ils contiennent exactement, et pourquoi certains ont un rôle spécial. Puis on les regarde bouger dans le débogueur.

---

## 3.1 Trente et une cases de 64 bits

ARM64 a **31 registres généraux**, `x0` à `x30`. « Général » veut dire que le processeur ne leur impose aucun rôle : tu peux calculer avec n'importe lequel. Chacun contient **64 bits**, soit 8 octets. Un registre contient toujours quelque chose, il n'est jamais « vide » : au démarrage c'est du hasard ou zéro, ensuite c'est ce que tu y as mis en dernier.

Un registre ne sait pas ce qu'il contient. `x1` peut contenir le nombre 14, ou une adresse, ou un caractère, ou n'importe quoi : ce sont des bits, et c'est **toi** qui décides ce qu'ils signifient, par la façon dont tu les utilises. C'est la grande différence avec un langage typé. Il n'y a pas d'entier, de pointeur ou de chaîne : il y a des nombres, et des instructions qui les interprètent.

### La vue 32 bits : w au lieu de x

Chaque registre `xN` a un alias `wN` qui désigne ses **32 bits de poids faible** (la moitié « basse »). `w0` est la moitié basse de `x0`, ce n'est pas un autre registre.

```asm
mov x0, #5      // x0 = 5, sur 64 bits
mov w0, #5      // x0 = 5 aussi : écrire dans w0 met les 32 bits hauts à zéro
add w1, w2, w3  // addition sur 32 bits (le résultat est tronqué à 32 bits)
add x1, x2, x3  // addition sur 64 bits
```

Règle à retenir : **écrire dans `wN` efface les 32 bits hauts de `xN`.** Le labo 02 te le fait constater : après `mov x3, #-1` (64 bits à 1) puis `mov w3, #5`, x3 vaut 5, pas un mélange.

Pourquoi deux tailles ? Parce que beaucoup de données font 32 bits (les `int` du C), et que certaines instructions vont plus vite ou se comportent différemment en 32 bits (les débordements, par exemple). Dans ce cours on utilise surtout les `x`, et les `w` quand on lit des données de 32 bits ou des octets.

---

## 3.2 Les registres spéciaux

À côté des 31 registres généraux, quelques cases à part :

- **`sp`**, le *stack pointer*, contient l'adresse du sommet de la **pile**. La pile est une zone de mémoire où on range temporairement des choses (on en parle au chapitre 7). Deux règles dès maintenant : ne pas y toucher sans savoir, et quand on y touche, `sp` doit rester un **multiple de 16**. Sinon le noyau tue le programme à la première occasion.
- **`pc`**, le *program counter*, contient l'adresse de l'instruction en cours. Le processeur l'augmente de 4 après chaque instruction ; les sauts (chapitre 6) le changent. On ne peut pas écrire dedans directement.
- **`xzr`** (et `wzr`), le **registre zéro** : un faux registre qui lit toujours 0, et où écrire ne fait rien. Très pratique : `mov x0, xzr` met 0 dans x0 ; `cmp x0, xzr` compare x0 à zéro.
- **`nzcv`**, les **flags** : quatre bits que certaines instructions positionnent pour dire « le résultat était Négatif », « Zéro », « avec retenue (Carry) », « avec débordement (oVerflow) ». C'est le mécanisme derrière tous les `if` (chapitre 6).

---

## 3.3 Les rôles par convention

Le processeur traite x0 et x19 exactement de la même façon. Mais **tout le monde** (le noyau, la bibliothèque C, le compilateur, toi) a convenu de rôles, pour pouvoir s'appeler les uns les autres sans se marcher dessus. Cette convention s'appelle l'**ABI** (*Application Binary Interface*). La voici, simplifiée ; tu y reviendras au chapitre 7.

| Registres | Rôle convenu | À retenir |
|---|---|---|
| `x0` à `x7` | les **paramètres** qu'on passe à une fonction ou à un appel système, dans l'ordre ; `x0` sert aussi à rendre le **résultat** | c'est pour ça que « écrire » lisait x0, x1, x2 |
| `x8` à `x15` | temporaires, libres | calcule dedans sans te poser de question |
| `x16`, `x17` | temporaires eux aussi, mais **x16 porte le numéro d'appel système** sur macOS | ne garde rien d'important dans x16 |
| `x18` | **réservé par Apple** | ne l'utilise jamais, même s'il a l'air libre |
| `x19` à `x28` | variables « qui doivent survivre » à un appel de fonction | si une fonction les utilise, elle doit les rendre intacts (chapitre 7) |
| `x29` | *frame pointer* | pour le débogueur et les piles d'appels (chapitre 7) |
| `x30` | *link register* : l'adresse où revenir après un appel de fonction | c'est `bl` qui l'écrit (chapitre 7) |

Pour l'instant, tu peux te contenter de : **paramètres et résultat dans x0-x7, brouillon dans x9-x15, jamais x18.** Le reste viendra quand on écrira des fonctions.

---

## 3.4 Le code de sortie, ton premier « affichage »

Tu ne sais pas encore afficher un nombre. Mais tu sais terminer un programme avec un code de sortie, et ce code, c'est le contenu de x0 au moment de l'appel système « terminer ». Le shell te le montre avec `echo $?`.

```asm
    mov x1, #10
    mov x2, #32
    add x0, x1, x2      // x0 = 42
    mov x16, #1         // terminer
    svc #0x80
```

`./prog ; echo $?` affiche `42`. C'est ton oscilloscope pour les quatre prochains chapitres.

Limite : le code de sortie n'a que **8 bits**, donc de 0 à 255. Si x0 vaut 300, le shell voit 300 modulo 256, soit 44. Si x0 est négatif, tu vois 256 moins la valeur. Le labo te le fait constater.

---

## 3.5 Voir les registres vivre : lldb

L'outil sérieux, c'est le débogueur **lldb**. Il lance ton programme en le tenant en laisse : tu avances d'une instruction à la fois et tu regardes les registres entre chaque.

```
$ lldb ./registres
(lldb) b _start          ← pose un point d'arrêt sur l'étiquette _start
(lldb) r                 ← lance ; le programme s'arrête à _start avant d'exécuter quoi que ce soit
(lldb) register read x0 x1 x2    ← montre trois registres
(lldb) si                ← exécute UNE instruction (step instruction)
(lldb) register read x0 x1 x2    ← regarde ce qui a changé
(lldb) si
...
(lldb) q                 ← quitter
```

Les valeurs s'affichent en hexadécimal (`0x000000000000002a` = 42). `register read -f d x0` affiche en décimal. `register read` tout seul montre tout, y compris `sp`, `pc` et `cpsr` (les flags).

Fais-le vraiment, avec le labo 02, sur chaque instruction. Voir `x0` passer de `0x0` à `0x2a` au moment du `add`, c'est le déclic. `make debug` dans chaque labo ouvre lldb déjà arrêté sur `_start`. L'antisèche complète est dans [`tools/lldb-antiseche.md`](../tools/lldb-antiseche.md).

---

## 3.6 À retenir

- 31 registres `x0`-`x30` de 64 bits ; `wN` = la moitié basse de `xN`, et y écrire efface la moitié haute.
- Un registre contient des bits, pas un type : c'est l'instruction qui décide du sens.
- `sp` (pile, multiple de 16), `pc` (instruction courante), `xzr` (toujours zéro), flags `nzcv`.
- Convention : paramètres et résultat dans `x0`-`x7`, brouillon `x9`-`x15`, `x16` = numéro de syscall, `x18` interdit, `x19`-`x30` réservés aux fonctions (chapitre 7).
- `echo $?` montre x0 à la fin (8 bits) ; lldb montre tout, à chaque instruction.

---

← [2. Les outils, et ton premier programme](02-outils-premier-programme.md) · [Sommaire](../README.md) · [4. Les instructions de calcul](04-instructions-de-calcul.md) →
