// Labo 01 — solution commentée.

.global _start
.align 2
.text

_start:
    mov x0, #1              // fd 1 = stdout (0 = stdin, 2 = stderr)
    adrp x1, msg@PAGE       // adrp : adresse de la page de 4 Ko contenant msg
    add x1, x1, msg@PAGEOFF //       + décalage dans la page = adresse exacte
    mov x2, #len            // longueur calculée par l'assembleur (voir en bas)
    mov x16, #4             // 4 = write (sys/syscall.h du SDK)
    svc #0x80               // appel au noyau ; au retour x0 = octets écrits

    mov x0, #0              // exit(0)
    mov x16, #1             // 1 = exit
    svc #0x80               // ne revient jamais

.data
msg: .ascii "Hello, ARM64!\n"
len = . - msg               // "." = adresse courante ; len = 14, calculé pour toi
