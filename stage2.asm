; ============================================================
; Jasper.6185 — STAGE-2 FAT12 LOADER
; LBA-to-CHS + ReadSectors routines
; Assemble: nasm -f bin stage2.asm -o stage2.bin
; ============================================================

bits 16
org 0x7E00          ; Typical stage-2 load address (immediately after boot sector)

; ------------------------------------------------------------------
; Entry point (stub — extend with root-directory search later)
; ------------------------------------------------------------------
stage2_start:
    mov si, stage2_banner
    call print_string
    ; Example: read sector LBA 19 (start of root directory on a standard 1.44 MB FAT12)
    ; mov ax, 19
    ; mov cx, 1
    ; mov bx, 0x8000
    ; call ReadSectors
    jmp $

; ------------------------------------------------------------------
; LBA_to_CHS: Translates LBA in AX to Cylinder, Head, Sector
; Input:  AX = LBA sector number
; Output: CL = Sector (bits 0-5) | Cylinder high (bits 6-7)
;         CH = Cylinder low (bits 0-7)
;         DH = Head
; Preserves AX
; ------------------------------------------------------------------
LBA_to_CHS:
    push ax
    push dx

    xor dx, dx
    div word [SectorsPerTrack]  ; AX = LBA / SPT, DX = LBA % SPT
    inc dx                      ; Sector numbering starts at 1
    mov cl, dl                  ; CL = Sector

    xor dx, dx
    div word [NumberOfHeads]    ; AX = Cylinder, DX = Head
    mov dh, dl                  ; DH = Head
    mov ch, al                  ; CH = Cylinder low 8 bits
    shl ah, 6
    or cl, ah                   ; High 2 bits of cylinder into CL

    pop dx
    pop ax
    ret

; ------------------------------------------------------------------
; ReadSectors: Reads sectors from disk into memory
; Input: AX = starting LBA
;        CL = number of sectors to read
;        ES:BX = destination buffer
; ------------------------------------------------------------------
ReadSectors:
    push ax
    push bx
    push cx
    push dx

.read_loop:
    push cx
    call LBA_to_CHS             ; AX → CH/DH/CL
    mov dl, [boot_drive]
    mov ah, 0x02
    mov al, 0x01                ; One sector at a time
    int 0x13
    jc .disk_error

    pop cx
    inc ax                      ; Next LBA
    add bx, 512
    loop .read_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret

.disk_error:
    mov si, err_msg
    call print_string
    cli
    hlt

; ------------------------------------------------------------------
; Minimal print helper (same style as boot sector)
; ------------------------------------------------------------------
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

; ------------------------------------------------------------------
; Data / BPB references (must match fat12_boot.asm values)
; ------------------------------------------------------------------
SectorsPerTrack dw 18
NumberOfHeads   dw 2
boot_drive      db 0            ; Filled by stage-1 before jump

stage2_banner   db "JASPER.6185 STAGE-2 LOADER", 13, 10, 0
err_msg         db "Disk read error!", 13, 10, 0
