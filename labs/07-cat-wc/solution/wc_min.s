// Labo 07 — solution wc minimal.

.global _start
.align 2
.text

_start:
    mov x19, #0                 // octets
    mov x20, #0                 // lignes
loop:
    mov x0, #0
    adrp x1, buf@PAGE
    add x1, x1, buf@PAGEOFF
    mov x2, #4096
    mov x16, #3                 // read(0, buf, 4096)
    svc #0x80
    cmp x0, #0
    b.le done                   // fin ou erreur

    add x19, x19, x0            // octets += n
    adrp x9, buf@PAGE
    add x9, x9, buf@PAGEOFF     // x9 = curseur
    add x10, x9, x0             // x10 = fin
scan:
    ldrb w11, [x9], #1
    cmp w11, #10                // '\n'
    cinc x20, x20, eq           // lignes += (w11 == 10)  — sans branchement
    cmp x9, x10
    b.lo scan
    b loop

done:
    mov x0, x20
    adrp x1, tbuf@PAGE
    add x1, x1, tbuf@PAGEOFF
    bl itoa
    bl print
    adrp x0, sp_@PAGE
    add x0, x0, sp_@PAGEOFF
    mov x1, #1
    bl print
    mov x0, x19
    adrp x1, tbuf@PAGE
    add x1, x1, tbuf@PAGEOFF
    bl itoa
    bl print
    adrp x0, nl@PAGE
    add x0, x0, nl@PAGEOFF
    mov x1, #1
    bl print
    mov x0, #0
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
sp_: .ascii " "
nl:  .ascii "\n"
.bss
buf:  .space 4096
tbuf: .space 24
