# Deux programmes dans ce labo : cat (complet) et wc_min (à compléter).
SDK     := $(shell xcrun -sdk macosx --show-sdk-path)
LDFLAGS := -lSystem -syslibroot $(SDK) -e _start -arch arm64

.PHONY: all run solution clean
all: cat wc_min

%: %.s
	as -o $@.o $<
	ld -o $@ $@.o $(LDFLAGS)

run: wc_min
	@printf "a\nb\n" | ./wc_min; echo "→ attendu : 2 4"

solution:
	as -o solution/wc_min.o solution/wc_min.s
	ld -o solution/wc_min solution/wc_min.o $(LDFLAGS)
	@printf "a\nb\n" | ./solution/wc_min; echo "→ attendu : 2 4"

clean:
	rm -f cat wc_min *.o solution/wc_min solution/*.o
