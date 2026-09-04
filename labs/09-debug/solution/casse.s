// Labo 09 — solution, les trois bugs corrigés et expliqués.

.global _main
.align 2
.text

compte:
    stp x29, x30, [sp, #-16]!   // BUG 2 : compte fait un bl → x30 est écrasé par l'adresse
    mov x29, sp                 //         de retour de helper ; sans sauvegarde, le ret final
    mov x9, #4                  //         retournait dans compte lui-même (boucle) ou ailleurs.
    mov x10, #0
1:  ldr x11, [x0], #8
    cmp x11, #0
    cinc x10, x10, ne
    subs x9, x9, #1
    b.ne 1b
    mov x0, x10
    bl helper
    ldp x29, x30, [sp], #16
    ret

helper:
    ret

_main:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    sub sp, sp, #16             // BUG 1 : sub sp, #8 laissait sp non aligné sur 16 →
                                //         crash (EXC_BAD_ACCESS / SIGSEGV) dans printf.
    adrp x0, tab@PAGE
    add x0, x0, tab@PAGEOFF
    bl compte
    str x0, [sp]                // BUG 3 : argument variadique → SUR LA PILE, pas dans x1
    adrp x0, fmt@PAGE           //         (ABI Apple) ; dans x1 printf lisait [sp] non initialisé.
    add x0, x0, fmt@PAGEOFF
    bl _printf

    add sp, sp, #16
    mov w0, #0
    ldp x29, x30, [sp], #16
    ret

.data
fmt: .asciz "Compte : %ld\n"
tab: .quad 5, 0, 7, 9
