// Labo 08 — solution. Fonction feuille : x0-x15 seulement, pas de prologue.

.global _somme
.align 2
.text

_somme:
    mov x2, #0                  // accumulateur
    cbz x1, done                // n == 0 → 0
loop:
    ldr x3, [x0], #8            // élément courant, avance de 8
    add x2, x2, x3
    subs x1, x1, #1
    b.ne loop
done:
    mov x0, x2                  // valeur de retour
    ret
