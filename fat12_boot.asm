; ============================================================
; Jasper.6185 — DOS FAT12 CORE BOOT RECORD
; 512-byte FAT12-style volume boot record
; Assemble: nasm -f bin fat12_boot.asm -o fat12_boot.bin
; ============================================================

bits 16
org 0x7C00

jmp short boot_start
nop

OEMName         db "JASPER6185"

; BIOS Parameter Block
BytesPerSector      dw 512
SectorsPerCluster   db 1
ReservedSectors     dw 1
NumberOfFATs        db 2
RootEntries         dw 224
TotalSectors16      dw 2880
MediaDescriptor     db 0xF0
SectorsPerFAT       dw 9
SectorsPerTrack     dw 18
NumberOfHeads       dw 2
HiddenSectors       dd 0
TotalSectors32      dd 0

DriveNumber         db 0
Reserved            db 0
BootSignature       db 0x29
VolumeSerialNumber  dd 0x61856185
VolumeLabel         db "JASPER6185"
FileSystemType      db "FAT12   "

boot_start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    cld

    mov [boot_drive], dl
    mov si, banner
    call print_string

halt:
    cli
    hlt
    jmp halt

print_string:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x07
    int 0x10
    jmp print_string
.done:
    ret

boot_drive db 0

banner db "JASPER.6185 FAT12 CORE BOOT RECORD", 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55
