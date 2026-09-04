// Labo 01 — premier programme : écrire un message avec le syscall write, puis exit.
// Sur macOS arm64 : numéro de syscall dans x16, arguments dans x0-x2, svc #0x80.

.global _start          // point d'entrée visible pour l'éditeur de liens
.align 2                // instructions alignées sur 4 octets
.text

_start:
    mov x0, #1              // TODO : descripteur de fichier de stdout
    adrp x1, msg@PAGE       // adresse de msg, en deux temps (page + décalage)
    add x1, x1, msg@PAGEOFF
    mov x2, #14             // TODO : longueur du message (compte les octets, \n compris)
    mov x16, #4             // syscall write
    svc #0x80

    mov x0, #0              // code de sortie
    mov x16, #1             // syscall exit
    svc #0x80

.data
msg: .ascii "Hello, ARM64!\n"
