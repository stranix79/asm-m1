# 2. Les outils, et ton premier programme

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 2 sur 12.* ← [1. Ta machine : Apple Silicon = ARM64](01-ta-machine-arm64.md) · [Sommaire](../README.md) · [3. Les registres](03-registres.md) →

> 🧪 Labo associé : [`labs/01-hello`](../labs/01-hello/README.md)

Ce chapitre ne suppose rien. On va lire ensemble un programme de douze lignes qui affiche `Hello, ARM64!`. Mais avant de le lire, il faut cinq idées. Prends le temps de les lire, tout le reste du cours s'appuie dessus.

---

## 2.1 Cinq idées avant la première ligne

### Idée 1 : le processeur ne comprend que des nombres

Quand tu écris en C ou en Python, une machine traduit ton texte en instructions que le processeur sait exécuter. Ces instructions sont des nombres : sur ARM64, chaque instruction est un nombre de 32 bits, c'est-à-dire 4 octets. `0xD2800020`, par exemple, veut dire « mets 1 dans le registre x0 ». Personne n'a envie d'écrire ça.

L'**assembleur** (le langage) est simplement une façon lisible d'écrire ces nombres : `mov x0, #1` au lieu de `0xD2800020`. **Une ligne = une instruction = 4 octets.** Le programme qui fait la traduction texte → nombres s'appelle aussi « l'assembleur » (la commande `as`). Rien n'est optimisé, rien n'est réorganisé : ce que tu écris est exactement ce que le processeur exécutera, dans l'ordre.

### Idée 2 : les registres, les mains du processeur

Le processeur ne travaille pas directement dans la mémoire. Il a un petit nombre de cases de travail à l'intérieur de lui, ultra rapides, qu'on appelle des **registres**. Sur ARM64 il y en a 31 pour tout faire, nommés `x0`, `x1`, … `x30`. Chacun contient un nombre de 64 bits (de 0 à 18 milliards de milliards, ou un négatif).

Analogie : la mémoire, ce sont les armoires de l'atelier. Les registres, ce sont tes deux mains et le plan de travail. Pour faire quoi que ce soit, il faut d'abord **prendre** les choses dans les mains. `mov x0, #1` : « mets le nombre 1 dans la case x0 ». C'est l'instruction la plus courante de tout l'assembleur.

Le chapitre 3 détaille les registres. Pour l'instant retiens : **x0 à x30 sont des cases où on met des nombres**, et certaines cases ont un rôle convenu (par exemple, x0 sert à passer le premier paramètre à qui on appelle).

### Idée 3 : la mémoire, un immense tableau d'octets numérotés

La mémoire de ton Mac est une longue rangée de cases d'un octet, numérotées de 0 à plusieurs milliards. Le numéro d'une case s'appelle son **adresse**. Le texte `Hello, ARM64!` est rangé quelque part dans cette rangée, un caractère par case, à partir d'une certaine adresse.

Retenir des adresses par cœur est impossible, donc on leur donne des noms. Dans le fichier source, un nom suivi de deux-points, comme `msg:`, s'appelle une **étiquette** (*label*). Ça veut dire : « l'adresse de ce qui suit s'appelle msg ». L'assembleur remplace le nom par le vrai numéro à ta place. `_start:` est aussi une étiquette : celle de la première instruction du programme.

### Idée 4 : le noyau, le seul qui a le droit de toucher au monde

Ton programme n'a pas le droit d'écrire à l'écran, de lire un fichier ou de parler au réseau. Seul le **noyau** de macOS (le cœur du système, qui tourne en permanence) a ces droits. Ton programme doit lui **demander un service**. Ça s'appelle un **appel système** (*syscall*).

Ça marche comme un guichet : tu remplis un formulaire (les registres), tu appuies sur la sonnette (l'instruction `svc`), le guichetier fait le travail, te rend la main, et te laisse la réponse dans un registre. Le formulaire a un format fixe sur macOS :

- `x16` : le numéro du service demandé (4 = « écrire », 1 = « terminer le programme »…) ;
- `x0`, `x1`, `x2` : les paramètres du service, dans l'ordre ;
- `svc #0x80` : la sonnette.

Pour « écrire », les paramètres sont : où écrire (x0 = 1 veut dire « la sortie standard », c'est-à-dire ton terminal), l'adresse du texte (x1), et le nombre d'octets (x2). C'est exactement le `write(1, msg, 14)` du C, sauf que là, c'est toi qui poses les paramètres dans les registres.

### Idée 5 : un fichier assembleur a deux zones et des directives

Un fichier `.s` contient deux sortes de lignes :

- les **instructions** (`mov`, `add`, `svc`…) : destinées au processeur, chacune deviendra 4 octets ;
- les **directives**, qui commencent par un point (`.text`, `.data`, `.global`, `.ascii`…) : destinées à l'assembleur, pour lui dire comment organiser le fichier. Elles ne deviennent pas des instructions.

Les deux directives principales découpent le fichier en **zones** (*sections*) : `.text` = « ce qui suit est du code », `.data` = « ce qui suit, ce sont des données (du texte, des nombres) ». Le code et les données sont séparés parce que le système protège le code en lecture seule.

Voilà. Cinq idées : instruction, registre, adresse et étiquette, appel système, sections. Tu peux maintenant lire le programme.

---

## 2.2 Le programme, ligne par ligne

```asm
.global _start
.align 2
.text

_start:
    mov x0, #1
    adrp x1, msg@PAGE
    add x1, x1, msg@PAGEOFF
    mov x2, #14
    mov x16, #4
    svc #0x80

    mov x0, #0
    mov x16, #1
    svc #0x80

.data
msg: .ascii "Hello, ARM64!\n"
```

Trois choses à savoir sur la forme : les lignes qui commencent par `//` sont des commentaires (il n'y en a pas ici pour garder le programme nu, la solution du labo est commentée). Les instructions sont indentées par habitude, l'assembleur s'en moque. Le `#` devant un nombre veut dire « ce nombre lui-même », pas « le contenu de la case numéro… ». On appelle ça un **immédiat**.

Maintenant, ligne par ligne.

| Ligne | En français | Pourquoi c'est là |
|---|---|---|
| `.global _start` | « L'étiquette `_start` doit être visible de l'extérieur du fichier. » | L'éditeur de liens (étape suivante) doit savoir où commence le programme. Sans ça, il ne trouve pas le point d'entrée. |
| `.align 2` | « Aligne ce qui suit sur une adresse multiple de 4 (2² = 4). » | Les instructions ARM64 doivent commencer à une adresse multiple de 4. Ligne rituelle, à mettre avant le code, toujours. |
| `.text` | « À partir d'ici, c'est du code. » | Zone code. |
| `_start:` | « L'adresse de l'instruction suivante s'appelle `_start`. » | C'est ici que le programme commence. Le `_` devant est une manie de macOS : tous les noms de code et de données ont un underscore devant. |
| `mov x0, #1` | « Mets 1 dans x0. » | Premier paramètre de « écrire » : 1 = sortie standard (ton terminal). |
| `adrp x1, msg@PAGE` | « Mets dans x1 l'adresse de la page de mémoire qui contient `msg`. » | Première moitié de « mets l'adresse de msg dans x1 ». Lis le paragraphe 2.3, c'est la seule ligne bizarre. |
| `add x1, x1, msg@PAGEOFF` | « Ajoute à x1 la position de `msg` dans sa page. » | Seconde moitié. Après ces deux lignes, x1 contient l'adresse exacte du texte. |
| `mov x2, #14` | « Mets 14 dans x2. » | Troisième paramètre : le nombre d'octets à écrire. `Hello, ARM64!` fait 13 caractères, plus le retour à la ligne `\n`, 14. Si tu te trompes, le texte est tronqué (trop court) ou suivi d'octets au hasard (trop long). |
| `mov x16, #4` | « Mets 4 dans x16. » | Le numéro du service : 4 = « écrire ». |
| `svc #0x80` | « Sonnette : appelle le noyau. » | Le noyau lit x16, voit « écrire », lit x0, x1, x2, affiche les 14 octets, et rend la main à la ligne suivante. |
| `mov x0, #0` | « Mets 0 dans x0. » | Paramètre de « terminer » : le code de sortie. 0 = tout s'est bien passé, par convention. |
| `mov x16, #1` | « Mets 1 dans x16. » | Service numéro 1 = « terminer le programme ». |
| `svc #0x80` | « Sonnette. » | Le noyau termine le programme. Cette ligne ne rend jamais la main. Sans elle, le processeur continuerait à exécuter ce qu'il y a après, c'est-à-dire n'importe quoi : crash garanti. |
| `.data` | « À partir d'ici, ce sont des données. » | Zone données. |
| `msg: .ascii "Hello, ARM64!\n"` | « Range ces 14 octets ici, et appelle leur adresse `msg`. » | `.ascii` range le texte tel quel, sans zéro final. `\n` est le retour à la ligne, un seul octet (valeur 10). |

Résumé du déroulé : on prépare quatre registres, on sonne, le noyau écrit ; on prépare deux registres, on sonne, le noyau termine. Un programme en assembleur, c'est toujours ça : préparer des registres, puis faire quelque chose avec.

---

## 2.3 La seule ligne bizarre : `adrp` + `add`

Pourquoi deux instructions pour mettre une adresse dans x1, alors qu'il en suffit d'une pour mettre 14 ?

Parce qu'une adresse est un nombre de 64 bits, et qu'une instruction ne fait que 32 bits. Une adresse ne rentre pas dans une instruction. ARM64 contourne le problème en deux temps :

1. `adrp x1, msg@PAGE` : la mémoire est découpée en **pages** de 4096 octets. Cette instruction met dans x1 l'adresse du début de la page où se trouve `msg`. Comme le programme et ses données sont proches, cette adresse se calcule par rapport à l'instruction elle-même, et ça tient dans 32 bits.
2. `add x1, x1, msg@PAGEOFF` : on ajoute la position de `msg` à l'intérieur de sa page (un nombre entre 0 et 4095, qui tient aussi).

`@PAGE` et `@PAGEOFF` sont des annotations pour l'assembleur, qui calcule les deux moitiés pour toi. Tu n'as pas à comprendre plus que ça : **pour obtenir l'adresse d'une étiquette, on écrit toujours ces deux lignes.** Copie-colle-les, change le registre et le nom. Tu les taperas cent fois dans ce cours.

---

## 2.4 De ton texte à un programme qui tourne

Ton fichier `hello.s` est du texte. Deux étapes pour en faire quelque chose que le Mac peut lancer.

**Étape 1, assembler** : `as -o hello.o hello.s`. La commande `as` lit le texte et produit `hello.o`, un **fichier objet** : les instructions traduites en nombres, les données, et une table qui dit « l'étiquette `_start` est à tel endroit, `msg` à tel autre ». Ce n'est pas encore un programme lançable.

**Étape 2, lier** : `ld -o hello hello.o -lSystem -syslibroot $(xcrun -sdk macosx --show-sdk-path) -e _start -arch arm64`. La commande `ld` (l'**éditeur de liens**) prend un ou plusieurs fichiers objets et fabrique un exécutable. La ligne est longue parce que macOS est exigeant. Chaque morceau :

| Morceau | Ce qu'il dit |
|---|---|
| `-o hello` | le nom du fichier produit |
| `hello.o` | le fichier objet à utiliser |
| `-lSystem` | « lie avec la bibliothèque System ». On ne s'en sert pas, mais macOS refuse de lancer un programme qui n'y est pas lié. Une manie de plus. |
| `-syslibroot $(xcrun …)` | où trouver cette bibliothèque (le SDK de Xcode ; `xcrun` donne le chemin) |
| `-e _start` | « le programme commence à l'étiquette `_start` ». Sans ça, `ld` cherche un `_main` à la manière du C. |
| `-arch arm64` | on fabrique un programme pour processeur ARM64 |

**Étape 3, lancer** : `./hello`. Tu dois voir `Hello, ARM64!`. Puis `echo $?` affiche `0` : c'est le code de sortie qu'on a mis dans x0 avant de terminer. C'est le seul moyen, pour l'instant, de voir un nombre calculé par ton programme. On s'en servira beaucoup.

Le raccourci : `clang -o hello hello.s -nostartfiles -e _start` fait les deux étapes en une commande. Le `Makefile` de chaque labo fait tout ça pour toi : `make run`. Mais tape la version longue au moins une fois, pour voir les deux fichiers apparaître.

---

## 2.5 Ce qui va mal tourner, et ce que ça veut dire

- `undefined symbol: _start` à l'édition de liens : il manque `.global _start`, ou tu as écrit `start` sans underscore.
- Le texte s'affiche tronqué : x2 trop petit. Suivi de caractères bizarres : x2 trop grand, tu affiches ce qu'il y a en mémoire après ton texte.
- `Killed: 9` ou `Segmentation fault` : en général une adresse fausse dans x1 (un `adrp` sans son `add`, ou l'inverse).
- Rien ne s'affiche et le programme se termine : x0 vaut autre chose que 1 (par exemple 0, la sortie standard c'est 1), ou x16 ne vaut pas 4.
- Le programme affiche puis « Bus error » : tu as oublié le `svc` de fin, le processeur a continué dans la zone données.

---

## 2.6 À retenir de ce chapitre

- Une ligne d'assembleur = une instruction du processeur. Les lignes qui commencent par un point sont des directives pour l'assembleur.
- `mov x0, #1` : mets 1 dans le registre x0. Les registres sont les cases de travail du processeur.
- Une étiquette (`msg:`) donne un nom à une adresse. `adrp` + `add … @PAGE / @PAGEOFF` mettent cette adresse dans un registre. Deux lignes, toujours les mêmes.
- Un appel système : numéro du service dans x16, paramètres dans x0, x1, x2, puis `svc #0x80`. Écrire = 4, terminer = 1.
- `as` traduit, `ld` fabrique l'exécutable, `./hello` lance, `echo $?` montre le code de sortie.

Va faire le [labo 01](../labs/01-hello/README.md) maintenant. Il te fait casser le programme de cinq façons différentes, c'est comme ça qu'on comprend chaque ligne.

---

← [1. Ta machine : Apple Silicon = ARM64](01-ta-machine-arm64.md) · [Sommaire](../README.md) · [3. Les registres](03-registres.md) →
