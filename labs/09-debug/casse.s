// Labo 09 — trois bugs à trouver avec lldb. Ne corrige pas sans avoir observé.

.global _main
.align 2
.text

// compte : retourne le nombre d'éléments non nuls d'un tableau de 4 mots 64 bits.
compte:
    mov x9, #4
    mov x10, #0
1:  ldr x11, [x0], #8
    cmp x11, #0
    cinc x10, x10, ne
    subs x9, x9, #1
    b.ne 1b
    mov x0, x10
    bl helper                   // (appel sans raison, mais il est là)
    ret

helper:
    ret

_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #8              // place pour l'argument de printf

    adrp x0, tab@PAGE
    add x0, x0, tab@PAGEOFF
    bl compte
    mov x1, x0                  // argument de printf
    adrp x0, fmt@PAGE
    add x0, x0, fmt@PAGEOFF
    bl _printf

    add sp, sp, #8
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

.data
fmt: .asciz "Compte : %ld\n"
tab: .quad 5, 0, 7, 9
