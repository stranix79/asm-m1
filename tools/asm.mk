# Règles communes à tous les labos. Inclus par chaque labs/*/Makefile.
#
#   make            → assemble + lie le fichier de l'exercice (variable SRC)
#   make run        → lance le binaire et affiche le code de sortie
#   make solution   → assemble + lance la solution (solution/*.s)
#   make debug      → ouvre lldb sur le binaire, arrêté sur _start
#   make clean
#
# Deux façons de produire un exécutable sur macOS arm64 :
#  - as + ld (ce qu'on fait ici : on voit chaque étape) ;
#  - clang fichier.s -nostartfiles -e _start (une commande, même résultat).
# -lSystem : même un programme sans libc doit être lié à libSystem sur macOS
# (le noyau exige un exécutable dyld-compatible). -e _start : notre point d'entrée.

AS      ?= as
LD      ?= ld
SDK     := $(shell xcrun -sdk macosx --show-sdk-path)
LDFLAGS ?= -lSystem -syslibroot $(SDK) -e _start -arch arm64
BIN     ?= $(basename $(SRC))

.PHONY: all run solution debug clean

all: $(BIN)

$(BIN): $(SRC)
	$(AS) -o $(BIN).o $(SRC)
	$(LD) -o $(BIN) $(BIN).o $(LDFLAGS)

run: $(BIN)
	./$(BIN); echo "→ code de sortie : $$?"

solution:
	$(AS) -o solution/$(BIN).o solution/$(SRC)
	$(LD) -o solution/$(BIN) solution/$(BIN).o $(LDFLAGS)
	./solution/$(BIN); echo "→ code de sortie : $$?"

debug: $(BIN)
	lldb ./$(BIN) -o "breakpoint set --name _start" -o run

clean:
	rm -f $(BIN) $(BIN).o solution/$(BIN) solution/$(BIN).o a.out
