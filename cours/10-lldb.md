# 10. Déboguer avec lldb

*Assembleur ARM64 sur Mac Apple Silicon — chapitre 10 sur 12.* ← [9. Mélanger C et assembleur](09-c-et-assembleur.md) · [Sommaire](../README.md) · [11. SIMD/NEON, juste pour voir](11-neon.md) →

> 🧪 Labo associé : [`labs/09-debug`](../labs/09-debug/README.md)

Tu l'utilises depuis le labo 02, le chapitre rassemble ce qui compte. [`tools/lldb-antiseche.md`](../tools/lldb-antiseche.md) reprend les commandes.

Méthode quand ça plante :
1. `lldb ./prog`, `r` : lldb s'arrête à l'instruction fautive et affiche la raison (`EXC_BAD_ACCESS` = adresse invalide, `EXC_BREAKPOINT` avec `brk` = assertion, `SIGILL` = instruction invalide ou pile désalignée).
2. `register read` : regarde les registres impliqués. `p/x $sp` doit finir par 0.
3. `disassemble -p` pour voir où tu es, `bt` pour savoir d'où tu viens.
4. `x/s`, `x/16xb` pour vérifier que la mémoire contient ce que tu crois.

Les trois pannes classiques du débutant ARM64 sur Mac : `sp` pas multiple de 16 (crash à l'appel de libc), x30 écrasé par un `bl` sans sauvegarde (retour vers nulle part), argument variadique mis dans x1 au lieu de la pile.

**Labo 09** : un programme livré cassé, trois bugs, à trouver avec lldb uniquement.

---

← [9. Mélanger C et assembleur](09-c-et-assembleur.md) · [Sommaire](../README.md) · [11. SIMD/NEON, juste pour voir](11-neon.md) →
