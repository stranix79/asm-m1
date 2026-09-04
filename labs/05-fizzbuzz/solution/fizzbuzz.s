// Labo 05 — solution.

.global _start
.align 2
.text

// modulo : x0 = x0 % x1 (détruit x9)
mod:
    udiv x9, x0, x1
    msub x0, x9, x1, x0
    ret

_start:
    mov x19, #1                 // i (callee-saved : survit aux bl)
loop:
    mov x0, x19
    mov x1, #15
    bl mod
    cbz x0, is_fizzbuzz
    mov x0, x19
    mov x1, #3
    bl mod
    cbz x0, is_fizz
    mov x0, x19
    mov x1, #5
    bl mod
    cbz x0, is_buzz

    mov x0, x19                 // sinon : le nombre
    adrp x1, buf@PAGE
    add x1, x1, buf@PAGEOFF
    bl itoa
    bl print
    adrp x0, nl@PAGE
    add x0, x0, nl@PAGEOFF
    mov x1, #1
    bl print
    b next

is_fizzbuzz:
    adrp x0, fizzbuzz@PAGE
    add x0, x0, fizzbuzz@PAGEOFF
    mov x1, #9
    bl print
    b next
is_fizz:
    adrp x0, fizz@PAGE
    add x0, x0, fizz@PAGEOFF
    mov x1, #5
    bl print
    b next
is_buzz:
    adrp x0, buzz@PAGE
    add x0, x0, buzz@PAGEOFF
    mov x1, #5
    bl print

next:
    add x19, x19, #1
    cmp x19, #15
    b.le loop

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
fizz:     .ascii "Fizz\n"
buzz:     .ascii "Buzz\n"
fizzbuzz: .ascii "FizzBuzz\n"
nl:       .ascii "\n"
.bss
buf: .space 24
