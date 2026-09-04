// Labo 03 — solution.

.global _start
.align 2
.text

_start:
    mov x1, #7
    mov x2, #6
    mov x3, #3
    mul x4, x1, x2          // 42
    add x4, x4, x3          // 45
    udiv x5, x4, x1         // 45 / 7 = 6 (tronqué)
    msub x0, x5, x1, x4     // 45 - 6*7 = 3  → x0 = reste

    ldr x9, =100000         // trop grand pour mov : l'assembleur le range dans une "literal pool"
    mov x8, #1000
    udiv x10, x9, x8        // 100
    lsl x11, x9, #3         // 800000
    lsr x12, x9, #1         // 50000
    and x13, x9, #0xff      // 0xA0 = 160 : immédiat bitmask valide
    ldr x14, =0x12345
    and x13, x9, x14        // pour un masque quelconque : passer par un registre

    mov x16, #1             // exit(3)
    svc #0x80
