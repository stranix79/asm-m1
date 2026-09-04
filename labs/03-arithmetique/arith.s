// Labo 03 — r = (7*6+3) % 7, sans instruction modulo.

.global _start
.align 2
.text

_start:
    mov x1, #7
    mov x2, #6
    mov x3, #3
    // TODO : x4 = x1 * x2 + x3          (mul puis add)
    // TODO : x5 = x4 / x1               (udiv)
    // TODO : x0 = x4 - x5 * x1          (msub x0, x5, x1, x4)

    mov x16, #1
    svc #0x80
