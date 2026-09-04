SDK     := $(shell xcrun -sdk macosx --show-sdk-path)
LDFLAGS := -lSystem -syslibroot $(SDK) -e _start -arch arm64
.PHONY: all test solution clean
all: wc_asm
wc_asm: wc_asm.s
	as -o wc_asm.o wc_asm.s
	ld -o wc_asm wc_asm.o $(LDFLAGS)
test: wc_asm
	@for f in ../../README.md ../../cours/08-syscalls-macos.md wc_asm.s; do \
	  printf "%-40s wc: %s | wc_asm: %s\n" "$$f" "$$(wc $$f | awk '{print $$1, $$2, $$3}')" "$$(./wc_asm $$f)"; done
solution:
	as -o solution/wc_asm.o solution/wc_asm.s
	ld -o solution/wc_asm solution/wc_asm.o $(LDFLAGS)
	@for f in ../../README.md ../../cours/08-syscalls-macos.md solution/wc_asm.s; do \
	  printf "%-40s wc: %s | wc_asm: %s\n" "$$f" "$$(wc $$f | awk '{print $$1, $$2, $$3}')" "$$(./solution/wc_asm $$f)"; done
	@printf "a b\nc\n" | ./solution/wc_asm; echo "→ attendu : 2 3 6"
	@./solution/wc_asm /nexistepas; echo "→ code de sortie : $$? (attendu 1)"
clean:
	rm -f wc_asm *.o solution/wc_asm solution/*.o
