.PHONY: all run solution debug clean
all: casse
casse: casse.s
	clang -g -o casse casse.s
run: casse
	./casse; echo "→ code de sortie : $$?"
solution:
	clang -g -o solution/casse solution/casse.s && ./solution/casse
debug: casse
	lldb ./casse
clean:
	rm -f casse solution/casse
	rm -rf casse.dSYM solution/casse.dSYM
