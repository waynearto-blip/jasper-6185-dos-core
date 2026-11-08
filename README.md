Jasper.6185 Boot Record Collection

This repository contains a compact set of x86 BIOS boot-sector examples plus a stage-2 FAT12 loader foundation.

Contents
- boot.asm: minimal 512-byte DOS-style boot sector
- shell.asm: interactive 512-byte shell with help/ver/clear/reboot
- fat12_boot.asm: FAT12-style volume boot sector with BPB
- stage2.asm: LBA-to-CHS conversion and BIOS INT 13h ReadSectors (stage-2 loader)
- Makefile: build and run helper commands
- .github/workflows/ci.yml: NASM build + 512-byte verification + QEMU smoke test

Build
make

Run individual targets
make run-boot
make run-shell
make run-fat12

Verify file size
stat -c '%s bytes' boot.bin
stat -c '%s bytes' shell.bin
stat -c '%s bytes' fat12_boot.bin

Verify boot signature
xxd -s 510 -l 2 boot.bin
xxd -s 510 -l 2 shell.bin
xxd -s 510 -l 2 fat12_boot.bin

Expected output
55 aa

Notes
- These are BIOS real-mode boot sectors.
- The three boot records are intentionally limited to one 512-byte sector.
- stage2.asm is a separate binary (loaded at 0x7E00) that provides the disk-reading engine for a full FAT12 file loader.
- They are suitable as educational bootloader examples, not full operating systems.

## Jasper.6185 Register Block

```
💎 Jasper.6185
DOS CORE BOOT RECORD — ALL NECESSARY CODE

Boot Architecture:
- x86 16-bit real mode
- BIOS boot protocol
- Load address: 0x7C00
- Sector size: 512 bytes
- Boot signature: 0x55AA
- Output interface: BIOS INT 10h
- Input interface: BIOS INT 16h
- Emulation target: QEMU

Core Components:
- boot.asm — minimal BIOS boot record
- shell.asm — interactive boot-sector shell
- fat12_boot.asm — FAT12-style volume boot record
- stage2.asm — LBA-to-CHS + ReadSectors stage-2 loader
- Makefile — build and emulation targets
- README.md — usage guide

Verification Constraints:
- Binary size must equal 512 bytes (boot records only).
- Final two bytes must equal 55 AA.
- Code must execute at 0x7C00.
- Stack must be initialized before BIOS calls.
- String output must use INT 10h, AH = 0Eh.
- Keyboard input must use INT 16h, AH = 00h.

Master Status:
- Boot record: COMPILED
- Shell record: COMPILED
- FAT12 record: COMPILED
- Stage-2 loader: COMPILED
- Signature: VALID
- BIOS state: READY
- Emulation target: QEMU
- Governance anchor: ACTIVE
```

## Create a bootable 1.44 MB floppy image

```bash
nasm -f bin fat12_boot.asm -o fat12_boot.bin
dd if=/dev/zero of=floppy.img bs=512 count=2880
dd if=fat12_boot.bin of=floppy.img conv=notrunc
qemu-system-x86_64 -drive format=raw,file=floppy.img
```

This is a working prototype for BIOS real-mode boot sectors, not a public industry standard.
