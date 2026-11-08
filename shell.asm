; ============================================================
; Jasper.6185 — DOS CORE SHELL BOOT RECORD
; 512-byte x86 BIOS boot sector
; Assemble: nasm -f bin shell.asm -o shell.bin
; Run:      qemu-system-x86_64 -drive format=raw,file=shell.bin
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

shell_loop:
    mov si, prompt
    call print_string

    mov di, input_buffer
    xor cx, cx

read_char:
    xor ah, ah
    int 0x16

    cmp al, 0x0D
    je command_enter

    cmp al, 0x08
    je command_backspace

    cmp al, 0x20
    jb read_char
    cmp al, 0x7E
    ja read_char

    cmp cx, 31
    jae read_char

    mov [di], al
    inc di
    inc cx

    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10

    jmp read_char

command_backspace:
    test cx, cx
    jz read_char

    dec di
    dec cx

    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10

    jmp read_char

command_enter:
    mov byte [di], 0
    call print_newline

    ; Normalize input to lowercase before compare
    mov si, input_buffer
    call lowercase_buffer

    mov si, input_buffer
    mov di, cmd_help
    call compare_string
    test ax, ax
    jnz do_help

    mov si, input_buffer
    mov di, cmd_ver
    call compare_string
    test ax, ax
    jnz do_ver

    mov si, input_buffer
    mov di, cmd_clear
    call compare_string
    test ax, ax
    jnz do_clear

    mov si, input_buffer
    mov di, cmd_reboot
    call compare_string
    test ax, ax
    jnz do_reboot

    mov si, msg_unknown
    call print_string
    jmp shell_loop

do_help:
    mov si, msg_help
    call print_string
    jmp shell_loop

do_ver:
    mov si, msg_ver
    call print_string
    jmp shell_loop

do_clear:
    mov ah, 0x06
    mov al, 0x00
    mov bh, 0x07
    mov cx, 0x0000
    mov dx, 0x184F
    int 0x10

    mov ah, 0x02
    mov bh, 0x00
    mov dx, 0x0000
    int 0x10

    jmp shell_loop

do_reboot:
    mov ax, 0x0040
    mov ds, ax
    mov word [0x0072], 0x0000
    jmp 0xFFFF:0x0000

compare_string:
    xor ax, ax
.next:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .not_equal
    test al, al
    jz .equal
    inc si
    inc di
    jmp .next
.equal:
    mov ax, 1
    ret
.not_equal:
    xor ax, ax
    ret

lowercase_buffer:
    mov bx, si
.lower_loop:
    mov al, [bx]
    test al, al
    jz .done
    cmp al, 'A'
    jb .next
    cmp al, 'Z'
    ja .next
    add al, 32
    mov [bx], al
.next:
    inc bx
    jmp .lower_loop
.done:
    ret

print_string:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0
    mov bl, 0x07
    int 0x10
    jmp print_string
.done:
    ret

print_newline:
    mov ah, 0x0E
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    ret

boot_drive db 0

banner      db "JASPER.6185 DOS CORE SHELL", 13, 10
            db "Type HELP for commands.", 13, 10, 0

prompt      db 13, 10, "JASPER> ", 0

cmd_help    db "help", 0
cmd_ver     db "ver", 0
cmd_clear   db "clear", 0
cmd_reboot  db "reboot", 0

msg_unknown db "Unknown command.", 13, 10, 0

msg_help    db 13, 10, "Commands:", 13, 10
            db "  help   - Show this help", 13, 10
            db "  ver    - Show shell version", 13, 10
            db "  clear  - Clear screen", 13, 10
            db "  reboot - Restart system", 13, 10, 0

msg_ver     db "JASPER.6185 DOS CORE SHELL v1.0", 13, 10, 0

input_buffer times 32 db 0

times 510-($-$$) db 0
dw 0xAA55
