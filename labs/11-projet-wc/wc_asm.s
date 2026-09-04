// Labo 11 — squelette : open/argv/lignes/octets sont là, il manque les mots.

.global _start
.align 2
.text

_start:
    // Sur macOS, dyld appelle le point d'entrée comme une fonction C :
    // x0 = argc, x1 = argv, x2 = envp (pas de argc sur la pile comme sous Linux).
    cmp x0, #2
    b.lt use_stdin
    ldr x0, [x1, #8]            // argv[1] (argv est un tableau de pointeurs de 8 octets)
    mov x1, #0                  // O_RDONLY
    mov x2, #0
    mov x16, #5                 // open
    svc #0x80
    b.cs open_failed            // flag C = erreur, x0 = errno
    mov x21, x0                 // fd
    b count
use_stdin:
    mov x21, #0

count:
    mov x19, #0                 // octets
    mov x20, #0                 // lignes
    mov x22, #0                 // mots
    mov x23, #0                 // état : 0 = hors mot, 1 = dans un mot
loop:
    mov x0, x21
    adrp x1, buf@PAGE
    add x1, x1, buf@PAGEOFF
    mov x2, #4096
    mov x16, #3                 // read
    svc #0x80
    cmp x0, #0
    b.le done
    add x19, x19, x0
    adrp x9, buf@PAGE
    add x9, x9, buf@PAGEOFF
    add x10, x9, x0
scan:
    ldrb w11, [x9], #1
    cmp w11, #10                // '\n' → ligne
    cinc x20, x20, eq
    // TODO : machine à états mots : si blanc (32, 9, 10, 13) → x23 = 0 ;
    //        sinon si x23 == 0 → x23 = 1 et x22 += 1
next:
    cmp x9, x10
    b.lo scan
    b loop

done:
    cbz x21, show
    mov x0, x21
    mov x16, #6                 // close
    svc #0x80
show:
    mov x0, x20
    bl show_num
    adrp x0, sp_@PAGE
    add x0, x0, sp_@PAGEOFF
    mov x1, #1
    bl print
    mov x0, x22
    bl show_num
    adrp x0, sp_@PAGE
    add x0, x0, sp_@PAGEOFF
    mov x1, #1
    bl print
    mov x0, x19
    bl show_num
    adrp x0, nl@PAGE
    add x0, x0, nl@PAGEOFF
    mov x1, #1
    bl print
    mov x0, #0
    mov x16, #1
    svc #0x80

open_failed:
    mov x0, #2                  // stderr
    adrp x1, err@PAGE
    add x1, x1, err@PAGEOFF
    mov x2, #errlen
    mov x16, #4
    svc #0x80
    mov x0, #1
    mov x16, #1
    svc #0x80

// show_num : affiche x0 en décimal (itoa + print). Appelle deux fonctions → prologue.
show_num:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    adrp x1, tbuf@PAGE
    add x1, x1, tbuf@PAGEOFF
    bl itoa
    bl print
    ldp x29, x30, [sp], #16
    ret

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
err: .ascii "wc_asm: impossible d'ouvrir\n"
errlen = . - err
.bss
buf:  .space 4096
tbuf: .space 24
