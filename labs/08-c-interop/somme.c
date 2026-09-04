#include <stdio.h>
#include <stdint.h>

/* Écrite en assembleur dans somme.s : les arguments arrivent dans x0 (tab) et x1 (n),
   le résultat repart dans x0. Même convention des deux côtés, rien à déclarer. */
extern int64_t somme(const int64_t *tab, int64_t n);

int main(void) {
    int64_t tab[] = {10, 20, 30, 40, 50};
    printf("somme = %lld\n", (long long)somme(tab, 5));
    return 0;
}
