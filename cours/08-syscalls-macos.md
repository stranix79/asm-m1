# 8. Parler au noyau : les syscalls macOS

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 8 sur 12.* ← [7. Fonctions, pile et convention d'appel](07-fonctions-pile.md) · [Sommaire](../README.md) · [9. Mélanger C et assembleur](09-c-et-assembleur.md) →

> 🧪 Labo associé : [`labs/07-cat-wc`](../labs/07-cat-wc/README.md)

Depuis le chapitre 2 tu utilises deux services du noyau, « écrire » et « terminer ». Ce chapitre élargit : lire un fichier ou le clavier, ouvrir un fichier, détecter une erreur. Avec ça, un programme en assembleur pur peut faire quelque chose d'utile. À la fin, tu écris un `cat` et un `wc`.

---

## 8.1 Le protocole, une fois pour toutes

Un appel système sur macOS arm64, c'est toujours :

1. le **numéro du service** dans `x16` ;
2. les **paramètres** dans `x0`, `x1`, `x2`… (jusqu'à x5), dans l'ordre de la fonction C correspondante ;
3. `svc #0x80` ;
4. au retour, le **résultat** dans `x0`.

Ces services sont ceux d'Unix (macOS est un Unix, de la famille BSD). Tu les connais sûrement par leur nom C : `write`, `read`, `open`, `close`, `exit`. Les paramètres sont les mêmes qu'en C, dans le même ordre. `man 2 read` te donne donc la doc du syscall.

| Service | x16 | x0 | x1 | x2 | Résultat dans x0 |
|---|---|---|---|---|---|
| exit | 1 | code de sortie | | | ne revient pas |
| read | 3 | descripteur | adresse du tampon | taille max | nombre d'octets lus, **0 = fin de fichier** |
| write | 4 | descripteur | adresse du texte | nombre d'octets | nombre d'octets écrits |
| open | 5 | adresse du chemin (`.asciz`) | mode (0 = lecture) | droits (0 si lecture) | un descripteur |
| close | 6 | descripteur | | | 0 |
| getpid | 20 | | | | le pid |

Un **descripteur** est un petit entier qui désigne un fichier ouvert. Trois sont ouverts d'office : 0 = l'entrée standard (le clavier, ou ce qu'un `|` ou un `<` envoie), 1 = la sortie standard, 2 = la sortie d'erreur. `open` en crée un nouveau, `close` le libère.

La liste complète des numéros est dans le SDK : `grep SYS_ $(xcrun --show-sdk-path)/usr/include/sys/syscall.h`.

---

## 8.2 Lire

`read` demande au noyau de déposer jusqu'à N octets dans un tampon à toi. Il en dépose ce qu'il a, et te dit combien. Un tampon dans `.bss`, et une boucle :

```asm
loop:
    mov x0, #0                  // descripteur 0 : entrée standard
    adrp x1, buf@PAGE
    add x1, x1, buf@PAGEOFF     // où déposer
    mov x2, #4096               // au plus 4096 octets
    mov x16, #3                 // read
    svc #0x80
    cmp x0, #0
    b.le done                   // 0 : plus rien à lire (fin de fichier) ; négatif : erreur

    // ici : x0 = nombre d'octets lus, dans buf
    // ... faire quelque chose avec ...
    b loop
done:
```

C'est le cœur de tout programme qui lit : boucler tant que `read` rend plus que zéro. Combien d'octets par tour ? Ce que le noyau veut : 4096, ou moins à la fin, ou la taille d'une ligne si l'entrée est un clavier. Ne suppose jamais que tu as tout d'un coup.

Un `cat` minimal, c'est cette boucle avec un `write` de x0 octets à chaque tour. Il est écrit dans le labo 07, lis-le : quinze lignes.

---

## 8.3 Détecter une erreur

Quand un service échoue (fichier inexistant, descripteur invalide), macOS fait deux choses : il met le **code d'erreur** (`errno`, un petit entier positif, 2 = « n'existe pas ») dans x0, et il **lève le flag C**. Le test, juste après le `svc` :

```asm
    mov x16, #5                 // open
    svc #0x80
    b.cs erreur                 // carry set → erreur, x0 = errno
    mov x21, x0                 // sinon x0 = le descripteur
```

`b.cs` (*carry set*) est le même saut que `b.hs`. C'est **différent de Linux**, où le noyau rend `-errno` dans x0 et ne touche pas aux flags. Si tu lis un tutoriel Linux, ce test change.

---

## 8.4 Différences avec Linux, pour tes recherches

La plupart des tutoriels ARM64 sur le web visent Linux ou Raspberry Pi. Ils se transposent presque tels quels, avec cinq changements :

| | macOS | Linux |
|---|---|---|
| numéro de syscall | `x16` | `x8` |
| instruction | `svc #0x80` | `svc #0` |
| numéros | BSD : write 4, read 3, exit 1, open 5 | write 64, read 63, exit 93, openat 56 |
| erreur | flag C + errno dans x0 | `-errno` dans x0 |
| symboles | `_start`, `_main` (underscore) | `_start`, `main` |

Rien d'autre ne change : les registres, les instructions, la convention d'appel sont les mêmes.

---

## 8.5 À retenir

- x16 = service, x0-x5 = paramètres dans l'ordre du C, `svc #0x80`, résultat dans x0.
- exit 1, read 3, write 4, open 5, close 6. Descripteurs : 0 entrée, 1 sortie, 2 erreur.
- `read` en boucle jusqu'à 0. Le tampon dans `.bss`.
- Erreur = flag C levé, `b.cs erreur`, errno dans x0.

---

← [7. Fonctions, pile et convention d'appel](07-fonctions-pile.md) · [Sommaire](../README.md) · [9. Mélanger C et assembleur](09-c-et-assembleur.md) →
