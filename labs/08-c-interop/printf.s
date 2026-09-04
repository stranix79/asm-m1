// Labo 08 — printf depuis l'assembleur. Piège Apple : les arguments variadiques
// (tout ce qui suit le format) vont SUR LA PILE, pas dans x1..x7.

.global _main
.align 2
.text

_main:
    stp x29, x30, [sp, #-16]!   // prologue : on va faire un bl
    mov x29, sp
    sub sp, sp, #32             // 3 arguments × 8 = 24, arrondi à 32 (alignement 16)

    adrp x9, name@PAGE
    add x9, x9, name@PAGEOFF
    str x9, [sp]                // 1er variadique : %s  → [sp]
    mov x9, #42
    str x9, [sp, #8]            // 2e : %ld → [sp+8]
    mov x9, #180
    str x9, [sp, #16]           // 3e : %ld → [sp+16]

    adrp x0, fmt@PAGE
    add x0, x0, fmt@PAGEOFF     // x0 = format (argument fixe, lui reste dans x0)
    bl _printf

    add sp, sp, #32
    mov w0, #0                  // return 0
    ldp x29, x30, [sp], #16
    ret

.data
fmt:  .asciz "%s a %ld ans et mesure %ld cm\n"
name: .asciz "Gilles"
