AS = ca65
CC = cc65
LD = ld65

.PHONY: clean

build: main.nes

%.o: %.s
	$(AS) -g --create-dep "$@.dep" --debug-info $< -o $@

main.nes: layout main.o
	$(LD) --dbgfile $@.dbg -C $^ -o $@

clean:
	rm -f *.dep *.o *.dbg

include $(wildcard *.dep)
