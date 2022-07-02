ASM = telemetry
C = main

all: ld

as: src/$(ASM).s
	as --32 $(ASM).s -o obj/$(ASM).o

ld: as
	ld -m elf_i386 obj/$(ASM).o -o bin/$(ASM)

gdb:
	gdb bin/$(ASM)

clear:
	rm -f obj/* bin/*

clear_obj:
	rm -f obj/*

run: ld
	bin/$(ASM)

exec:
	./bin/telemetry input/in_1.txt output.txt

gcc: src/$(ASM).s src/$(C).c
	gcc -m32 -c -o obj/$(C).o src/$(C).c
	gcc -m32 -c -o obj/$(ASM).o src/$(ASM).s
	gcc -m32 -o bin/$(ASM) obj/*.o

gdbc: src/$(ASM).s src/$(C).c
	gcc -m32 -ggdb -c -o obj/$(C).o src/$(C).c
	gcc -m32 -ggdb -c -o obj/$(ASM).o src/$(ASM).s
	gcc -m32 -ggdb -o bin/$(ASM) obj/*.o
	gdb bin/$(ASM)

diff: bin/$(ASM)
	diff -s output.txt output/out_1.txt