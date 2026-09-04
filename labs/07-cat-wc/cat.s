// Labo 07 — cat minimal : recopie stdin sur stdout, bloc par bloc.

.global _start
.align 2
.text

_start:
loop:
    mov x0, #0                  // fd 0 = stdin
    adrp x1, buf@PAGE
    add x1, x1, buf@PAGEOFF
    mov x2, #4096               // taille max à lire
    mov x16, #3                 // read
    svc #0x80
    cmp x0, #0
    b.le done                   // 0 = fin de fichier, <0 (ou flag C) = erreur

    mov x2, x0                  // nombre d'octets lus
    mov x0, #1                  // stdout
    adrp x1, buf@PAGE
    add x1, x1, buf@PAGEOFF
    mov x16, #4                 // write
    svc #0x80
    b loop

done:
    mov x0, #0
    mov x16, #1
    svc #0x80

.bss
buf: .space 4096
