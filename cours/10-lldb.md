# 10. Déboguer avec lldb

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 10 sur 12.* ← [9. Mélanger C et assembleur](09-c-et-assembleur.md) · [Sommaire](../README.md) · [11. SIMD/NEON, juste pour voir](11-neon.md) →

> 🧪 Labo associé : [`labs/09-debug`](../labs/09-debug/README.md)

Tu utilises lldb depuis le chapitre 3 pour regarder des registres. Ce chapitre en fait un outil de diagnostic : que faire quand un programme plante, boucle ou affiche n'importe quoi. En assembleur, il n'y a pas de message d'erreur lisible, il n'y a que l'état de la machine. lldb te le montre.

---

## 10.1 Les commandes qui comptent

L'antisèche complète est dans [`tools/lldb-antiseche.md`](../tools/lldb-antiseche.md). Les dix qui servent tout le temps :

| Commande | Effet |
|---|---|
| `lldb ./prog` | charge le programme sans le lancer |
| `b _start` ou `b fact` | point d'arrêt sur une étiquette |
| `r` | lance (s'arrête au premier point d'arrêt, ou au crash) |
| `si` | exécute une instruction |
| `n` | idem, mais passe par-dessus un `bl` sans entrer dedans |
| `c` | continue jusqu'au prochain arrêt |
| `register read` / `register read x0 x1` | les registres (`-f d` en décimal) |
| `disassemble -p` | le code autour de l'instruction courante |
| `x/16xb $sp` / `x/s $x1` | la mémoire : 16 octets en hexa à sp / la chaîne à l'adresse x1 |
| `bt` | la pile d'appels (marche si tes fonctions posent x29) |

Ajoute `-g` à la commande clang (`clang -g …`) pour que lldb connaisse les numéros de ligne de ton `.s` : `b casse.s:24` devient possible, et `disassemble` montre le source. Les Makefile des labos le font quand c'est utile.

---

## 10.2 Reconnaître la panne

Quand tu fais `r` et que le programme s'arrête tout seul, lldb affiche la **raison**. Elle dit presque toujours ce qui s'est passé :

- **`EXC_BAD_ACCESS (code=1, address=0x…)`** : lecture ou écriture à une adresse invalide. Regarde l'adresse : `0x0` ou tout petit = un registre contenait 0 au lieu d'une adresse (un `adrp` oublié, un `ldr` sur un registre non initialisé) ; une adresse « presque bonne » = un décalage faux ou un tableau dépassé. `disassemble -p` te montre l'instruction fautive, `register read` le registre en cause.
- **`EXC_BAD_ACCESS` au fond de la libc, dans `printf` ou `puts`** alors que ton code a l'air correct : `p/x $sp`. S'il ne finit pas par `0`, ta pile est désalignée.
- **`EXC_BREAKPOINT`** sur une instruction `brk` : une assertion de la libc, ou un `brk` que tu as mis.
- **`SIGILL` / `EXC_BAD_INSTRUCTION`** : le processeur a essayé d'exécuter des octets qui ne sont pas une instruction. En général `pc` est parti dans la zone données (un `svc` exit oublié) ou dans une adresse de retour fausse (x30 écrasé).
- **Le programme ne s'arrête jamais** : boucle infinie. `Ctrl-C` dans lldb, puis `disassemble -p` et `bt` : où tourne-t-il, et d'où vient-il ? Un `ret` qui revient au milieu de la fonction qui l'a appelé = x30 écrasé par un `bl` sans sauvegarde.
- **Ça tourne, mais le résultat est faux** : pose un point d'arrêt avant le calcul, `si` pas à pas, et compare chaque registre à ce que tu attendais. Sur Mac, un `printf` faux = argument variadique dans x1 au lieu de la pile.

---

## 10.3 Une méthode

1. Reproduis sous lldb : `lldb ./prog`, `r`.
2. Lis la raison de l'arrêt, et l'instruction : `disassemble -p`.
3. Lis les registres impliqués dans cette instruction. Est-ce que l'adresse a l'air d'une adresse ? Est-ce que `sp` finit par 0 ?
4. Remonte : `bt`. D'où vient-on ? Si `bt` est incohérent, c'est souvent la pile elle-même qui est cassée.
5. Vérifie la mémoire : `x/s` sur les chaînes, `x/4xg` sur les tableaux.
6. Pose un point d'arrêt un peu avant et refais en `si`.

Le labo 09 te livre un programme avec trois pannes différentes, à trouver avec cette méthode et rien d'autre. Fais-le sans regarder la solution : c'est le meilleur entraînement du cours.

---

## 10.4 À retenir

- `b`, `r`, `si`, `register read`, `disassemble -p`, `x/`, `bt` : tout tient là.
- La raison de l'arrêt dit presque tout : adresse invalide, pile désalignée, instruction invalide, boucle.
- Les trois pannes classiques sur Mac : `sp` non multiple de 16, x30 écrasé par un `bl` sans `stp`, variadique dans un registre.

---

← [9. Mélanger C et assembleur](09-c-et-assembleur.md) · [Sommaire](../README.md) · [11. SIMD/NEON, juste pour voir](11-neon.md) →
