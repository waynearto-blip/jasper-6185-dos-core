; ============================================================
; Jasper.6185 — DOS CORE BOOT RECORD
; Minimal 512-byte x86 BIOS boot sector
; Assemble: nasm -f bin boot.asm -o boot.bin
; Run:      qemu-system-x86_64 -drive format=raw,file=boot.bin
; ============================================================

bits 16
org 0x7C00

start:
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

banner db "JASPER.6185 DOS CORE BOOT RECORD", 13, 10, 0

; Pad to byte 510
times 510-($-$$) db 0

; Mandatory BIOS boot signature
dw 0xAA55
