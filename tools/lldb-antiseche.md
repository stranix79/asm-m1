# lldb — antisèche pour l'assembleur

```
lldb ./prog                    # charger le programme
(lldb) b _start                # point d'arrêt sur le label _start   (aussi : b main, b fichier.s:12)
(lldb) r                       # run (démarre et s'arrête au point d'arrêt)
(lldb) si                      # step instruction : exécute UNE instruction (n = next, saute par-dessus un bl)
(lldb) c                       # continue jusqu'au prochain point d'arrêt / fin
(lldb) register read           # tous les registres généraux
(lldb) register read x0 x1 sp  # quelques-uns
(lldb) register read -f d x0   # x0 en décimal (-f x hexa, -f b binaire, -f s chaîne si adresse)
(lldb) register write x0 42    # modifier un registre à la volée
(lldb) disassemble -p          # code autour de pc      (-n _start : toute la fonction)
(lldb) x/16xb $sp              # 16 octets en hexa à partir de sp
(lldb) x/4xg $sp               # 4 mots de 64 bits
(lldb) x/s $x1                 # la chaîne pointée par x1
(lldb) memory read -f d -c 4 -s 4 $x1   # 4 entiers 32 bits signés
(lldb) bt                      # pile d'appels (marche si tu as posé x29/x30 proprement)
(lldb) p/x $x0                 # expression, résultat en hexa
(lldb) q                       # quitter
```

Astuce : `register read cpsr` montre les flags ; le bit 31 = N, 30 = Z, 29 = C, 28 = V.
En pratique `p/t $cpsr` puis lire les 4 premiers bits de gauche.
