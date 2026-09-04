# 8. Parler au noyau : les syscalls macOS

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 8 sur 12.* ← [7. Fonctions, pile et convention d'appel](07-fonctions-pile.md) · [Sommaire](../README.md) · [9. Mélanger C et assembleur](09-c-et-assembleur.md) →

> 🧪 Labo associé : [`labs/07-cat-wc`](../labs/07-cat-wc/README.md)

Sur macOS arm64 : numéro dans **x16**, arguments dans x0…x5, `svc #0x80`, résultat dans x0. En cas d'erreur, le flag **C est mis** et x0 contient l'errno (à la différence de Linux qui renvoie `-errno`).

Les numéros sont ceux de BSD (fichier `sys/syscall.h` du SDK) :

| Syscall | x16 | x0, x1, x2 |
|---|---|---|
| exit | 1 | code |
| fork | 2 | — |
| read | 3 | fd, buffer, taille → x0 = octets lus (0 = fin) |
| write | 4 | fd, buffer, taille → x0 = octets écrits |
| open | 5 | chemin (asciz), flags, mode → x0 = fd |
| close | 6 | fd |
| getpid | 20 | — |
| lseek | 199 | fd, offset, whence |

`grep -n "SYS_write\|SYS_read\|SYS_open" $(xcrun --show-sdk-path)/usr/include/sys/syscall.h` pour la liste complète.

Différences avec Linux, pour tes souvenirs et les tutos du web : Linux met le numéro dans `x8`, utilise `svc #0`, et write = 64, exit = 93. Un tutoriel « ARM64 Linux » se transpose donc en changeant le registre et les numéros, rien d'autre.

**Labo 07** : un `cat` minimal (read en boucle sur stdin, write sur stdout), puis un compteur d'octets et de lignes, façon `wc`. C'est le premier programme utile du cours.

---

← [7. Fonctions, pile et convention d'appel](07-fonctions-pile.md) · [Sommaire](../README.md) · [9. Mélanger C et assembleur](09-c-et-assembleur.md) →
