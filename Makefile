ASM = nasm
ASMFLAGS = -f bin
QEMU = qemu-system-x86_64

all: boot.bin shell.bin fat12_boot.bin

boot.bin: boot.asm
	$(ASM) $(ASMFLAGS) boot.asm -o boot.bin

shell.bin: shell.asm
	$(ASM) $(ASMFLAGS) shell.asm -o shell.bin

fat12_boot.bin: fat12_boot.asm
	$(ASM) $(ASMFLAGS) fat12_boot.asm -o fat12_boot.bin

run-boot: boot.bin
	$(QEMU) -drive format=raw,file=boot.bin

run-shell: shell.bin
	$(QEMU) -drive format=raw,file=shell.bin

run-fat12: fat12_boot.bin
	$(QEMU) -drive format=raw,file=fat12_boot.bin

clean:
	rm -f boot.bin shell.bin fat12_boot.bin

.PHONY: all run-boot run-shell run-fat12 clean
