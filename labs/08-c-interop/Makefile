# Ici c'est clang qui lie, avec le démarreur C et la libc.
.PHONY: all printf somme solution clean
all: printf somme

printf: printf.s
	clang -o printf printf.s

somme: somme.c somme.s
	clang -o somme somme.c somme.s

solution:
	clang -o solution/somme somme.c solution/somme.s && ./solution/somme

clean:
	rm -f printf somme solution/somme
