// Labo 10 — solution.

.global _start
.align 2
.text

_start:
    adrp x0, a@PAGE
    add x0, x0, a@PAGEOFF
    adrp x1, b@PAGE
    add x1, x1, b@PAGEOFF
    adrp x2, c@PAGE
    add x2, x2, c@PAGEOFF

    // version NEON : 4 lanes de 32 bits, une instruction par étape
    ld1 {v0.4s}, [x0]           // v0 = {1, 2, 3, 4}
    ld1 {v1.4s}, [x1]           // v1 = {10, 20, 30, 40}
    add v2.4s, v0.4s, v1.4s     // v2 = {11, 22, 33, 44} en une instruction
    st1 {v2.4s}, [x2]           // c = v2

    // affichage des 4 résultats
    adrp x19, c@PAGE
    add x19, x19, c@PAGEOFF
    mov x20, #0
show:
    ldr w0, [x19, x20, lsl #2]
    adrp x1, buf@PAGE
    add x1, x1, buf@PAGEOFF
    bl itoa
    bl print
    add x20, x20, #1
    cmp x20, #4
    b.eq fin
    adrp x0, sp_@PAGE
    add x0, x0, sp_@PAGEOFF
    mov x1, #1
    bl print
    b show
fin:
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
.align 4
a: .word 1, 2, 3, 4
b: .word 10, 20, 30, 40
sp_: .ascii " "
nl:  .ascii "\n"
.bss
.align 4
c:   .space 16
buf: .space 24
