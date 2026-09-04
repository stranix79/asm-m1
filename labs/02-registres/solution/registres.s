// Labo 02 — solution.

.global _start
.align 2
.text

_start:
    mov x1, #10
    mov x2, #32
    add x0, x1, x2          // x0 = 42 : ce sera le code de sortie

    mov x3, #-1             // 64 bits à 1
    mov w3, #5              // vue 32 bits : les bits 32-63 sont mis à 0 → x3 = 5

    subs x4, x1, x2         // 10 - 32 = -22 : flag N levé (résultat négatif)
    subs x4, x2, x1         // 32 - 10 = 22 : N retombe, C levé (pas d'emprunt)

    mov x16, #1             // exit(x0) : seul l'octet bas de x0 est visible par le shell
    svc #0x80
