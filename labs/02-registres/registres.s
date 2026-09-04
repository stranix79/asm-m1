// Labo 02 — registres 64/32 bits et code de sortie.

.global _start
.align 2
.text

_start:
    mov x1, #10
    mov x2, #32
    // TODO : x0 = x1 + x2

    mov x3, #-1             // x3 = 0xFFFFFFFFFFFFFFFF
    mov w3, #5              // écrire w3 remet à zéro les 32 bits hauts : x3 = 5

    mov x16, #1             // exit(x0)
    svc #0x80
