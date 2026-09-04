// Labo 04 — solution.

.global _start
.align 2
.text

_start:
    adrp x19, tab@PAGE
    add x19, x19, tab@PAGEOFF
    mov x20, #5
    mov x22, #0                 // somme
    mov x21, #0                 // max

loop:
    ldr w9, [x19], #4           // w9 = *x19 ; x19 += 4  (post-incrément)
    add x22, x22, x9            // somme (x9 : les 32 bits hauts sont à 0 après ldr w9)
    cmp x9, x21
    csel x21, x9, x21, gt       // max = (x9 > max) ? x9 : max — sans branchement
    subs x20, x20, #1           // compteur, pose les flags
    b.ne loop

    mov x0, x21                 // max = 42
    adrp x1, buf@PAGE
    add x1, x1, buf@PAGEOFF
    bl itoa                     // → x0 = "42", x1 = 2
    bl print
    adrp x0, nl@PAGE
    add x0, x0, nl@PAGEOFF
    mov x1, #1
    bl print

    mov x0, x22                 // exit(75)
    mov x16, #1
    svc #0x80

// ---------------------------------------------------------------
// itoa : convertit x0 (entier non signé 64 bits) en texte décimal.
//   entrée : x0 = valeur, x1 = adresse d'un tampon d'au moins 21 octets
//   sortie : x0 = adresse du premier chiffre, x1 = longueur
// Fonction feuille : n'appelle personne, n'utilise que x0-x15 → pas de prologue.
// Principe : on écrit les chiffres de droite à gauche depuis la fin du tampon
// (valeur % 10 donne le dernier chiffre), en divisant par 10 à chaque tour.
// ---------------------------------------------------------------
itoa:
    add x2, x1, #20         // x2 = curseur, on part de la fin du tampon
    mov x3, #10
    mov x4, x2              // x4 = fin (pour calculer la longueur)
1:
    udiv x5, x0, x3         // x5 = x0 / 10
    msub x6, x5, x3, x0     // x6 = x0 - x5*10 = x0 % 10
    add x6, x6, #'0'        // chiffre → caractère ASCII
    sub x2, x2, #1
    strb w6, [x2]           // on pose le caractère
    mov x0, x5
    cbnz x0, 1b             // tant qu'il reste quelque chose à diviser
    mov x0, x2              // début du texte
    sub x1, x4, x2          // longueur
    ret

// print : écrit x1 octets depuis x0 sur stdout (syscall write).
print:
    mov x2, x1              // longueur
    mov x1, x0              // adresse
    mov x0, #1              // stdout
    mov x16, #4             // write
    svc #0x80
    ret

.data
tab: .word 3, 17, 5, 42, 8
nl:  .ascii "\n"
.bss
buf: .space 24
