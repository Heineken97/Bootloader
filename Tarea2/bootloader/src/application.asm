use16
org 8000h

SCREEN_WIDTH equ 320
SCREEN_HEIGHT equ 200
VIDEO_MEMORY equ 0A000h
TEXT_MODE equ 03h
CHAR_WIDTH equ 8
CHAR_HEIGHT equ 16

mov ax, 0013h
int 10h
mov ax, VIDEO_MEMORY
mov es, ax
mov al, 0x01
mov cx, SCREEN_WIDTH * SCREEN_HEIGHT
mov di, 0
rep stosb
mov ax, TEXT_MODE
int 10h

call random_position_1
call write_string_Joseph

call random_position_2
call write_string_Ruben

jmp $

write_string_Joseph:
    mov si, joseph_string
    call write_string
    ret

write_string_Ruben:
    mov si, ruben_string
    call write_string
    ret

write_string:
    mov ah, 0x0F
    mov bx, [position_x]
    mov cx, [position_y]
    call set_cursor_position
.next_char:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 10h
    jmp .next_char
.done:
    ret

set_cursor_position:
    mov ax, cx
    mov dx, bx
    mov ah, 02h
    int 10h
    ret

random_position_1:
    in al, 40h
    and al, 0x1F
    mov bl, SCREEN_WIDTH / CHAR_WIDTH - 1
    mul bl
    mov [position_x], al
    in al, 40h
    and al, 0x1F
    mov bl, SCREEN_HEIGHT / CHAR_HEIGHT - 1
    mul bl
    mov [position_y], al
    ret

random_position_2:
    in al, 40h
    and al, 0x1F
    mov bl, SCREEN_WIDTH / CHAR_WIDTH - 1
    mul bl
    mov [position_x], al
    in al, 40h
    and al, 0x1F
    mov bl, SCREEN_HEIGHT / CHAR_HEIGHT - 1
    mul bl
    mov [position_y], al
    ret

joseph_string db 'Joseph', 0
ruben_string db 'Ruben', 0

position_x dw 0
position_y dw 0

times 510-($-$$) db 0
dw 0xAA55
