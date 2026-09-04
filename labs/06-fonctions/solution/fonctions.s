// Labo 06 — solution.

.global _start
.align 2
.text

// strlen : fonction feuille, aucun registre callee-saved touché → pas de prologue.
strlen:
    mov x1, x0
1:  ldrb w2, [x1], #1           // lit un octet, avance
    cbnz w2, 1b                 // tant que ce n'est pas le 0 final
    sub x0, x1, x0              // x1 est un cran après le 0
    sub x0, x0, #1
    ret

// fact : récursive → doit sauver x30 (écrasé par le bl interne) et x19 (n).
fact:
    stp x29, x30, [sp, #-32]!   // réserve 32 octets : fp/lr en [sp], x19/x20 en [sp+16]
    mov x29, sp
    stp x19, x20, [sp, #16]
    mov x19, x0                 // n
    cmp x0, #1
    b.le 1f                     // n <= 1 → résultat 1
    sub x0, x0, #1
    bl fact                     // x0 = (n-1)!
    mul x0, x0, x19             // n * (n-1)!
    b 2f
1:  mov x0, #1
2:  ldp x19, x20, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

_start:
    adrp x0, hello@PAGE
    add x0, x0, hello@PAGEOFF
    bl strlen
    mov x19, x0                 // 7

    mov x0, #5
    bl fact                     // 120
    adrp x1, buf@PAGE
    add x1, x1, buf@PAGEOFF
    bl itoa
    bl print
    adrp x0, nl@PAGE
    add x0, x0, nl@PAGEOFF
    mov x1, #1
    bl print

    mov x0, x19                 // exit(strlen)
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
hello: .asciz "Bonjour"
nl:    .ascii "\n"
.bss
buf: .space 24
