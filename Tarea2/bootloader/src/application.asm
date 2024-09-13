use16
org 8000h

SCREEN_WIDTH equ 80        ; Ancho en caracteres del modo texto (80 columnas)
SCREEN_HEIGHT equ 25       ; Alto en líneas de texto del modo texto (25 filas)
TEXT_MODE equ 03h          ; Modo de texto 80x25
STRING_LENGTH equ 15       ; Longitud total de la cadena de texto "Joseph y Ruben" (14 caracteres + 1 terminador nulo)

mov ax, TEXT_MODE
int 10h                   ; Configurar el modo de texto 80x25

call random_position_Joseph
call write_string_Joseph
call random_position_Ruben
call write_string_Ruben

jmp main_loop

write_string_Joseph:
    mov si, joseph_string
    mov bx, [joseph_x]
    mov cx, [joseph_y]
    call write_string
    ret

write_string_Ruben:
    mov si, ruben_string
    mov bx, [ruben_x]
    mov cx, [ruben_y]
    call write_string
    ret

write_string:
    mov ah, 0x0F
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

main_loop:
    call check_key_press
    jmp main_loop

check_key_press:
    mov ah, 01h          ; Verificar si hay una tecla presionada
    int 16h
    jz no_key            ; Si no hay tecla presionada, saltar

    mov ah, 0          ; Obtener la tecla presionada
    int 16h

    cmp ah, 48h          ; Si es 'W' (arriba)
    je move_up
    cmp ah, 50h          ; Si es 'S' (abajo)
    je move_down
    cmp ah, 4Bh          ; Si es 'A' (izquierda)
    je move_left
    cmp ah,20h     ; Verificar si la tecla presionada fue "Space"
	jne salir_bootloader	; Si no fue "Space", espera
no_key:
    ret

move_up:
    call move_up_Joseph
    call move_up_Ruben
    call clear_screen
    call write_string_Joseph
    call write_string_Ruben
    ret

move_down:
    call move_down_Joseph
    call move_down_Ruben
    call clear_screen
    call write_string_Joseph
    call write_string_Ruben
    ret

move_left:
    call move_left_Joseph
    call move_left_Ruben
    call clear_screen
    call write_string_Joseph
    call write_string_Ruben
    ret

move_right:
    call move_right_Joseph
    call move_right_Ruben
    call clear_screen
    call write_string_Joseph
    call write_string_Ruben
    ret

move_up_Joseph:
    dec word [joseph_y]
    cmp word [joseph_y], 0
    jge done_move_up_Joseph
    mov word [joseph_y], SCREEN_HEIGHT - 1
done_move_up_Joseph:
    ret

move_down_Joseph:
    inc word [joseph_y]
    cmp word [joseph_y], SCREEN_HEIGHT
    jge done_move_down_Joseph
    mov word [joseph_y], 0
done_move_down_Joseph:
    ret

move_left_Joseph:
    dec word [joseph_x]
    cmp word [joseph_x], 0
    jge done_move_left_Joseph
    mov word [joseph_x], SCREEN_WIDTH - STRING_LENGTH
done_move_left_Joseph:
    ret

move_right_Joseph:
    inc word [joseph_x]
    cmp word [joseph_x], SCREEN_WIDTH - STRING_LENGTH
    jle done_move_right_Joseph
    mov word [joseph_x], 0
done_move_right_Joseph:
    ret

move_up_Ruben:
    dec word [ruben_y]
    cmp word [ruben_y], 0
    jge done_move_up_Ruben
    mov word [ruben_y], SCREEN_HEIGHT - 1
done_move_up_Ruben:
    ret

move_down_Ruben:
    inc word [ruben_y]
    cmp word [ruben_y], SCREEN_HEIGHT
    jge done_move_down_Ruben
    mov word [ruben_y], 0
done_move_down_Ruben:
    ret

move_left_Ruben:
    dec word [ruben_x]
    cmp word [ruben_x], 0
    jge done_move_left_Ruben
    mov word [ruben_x], SCREEN_WIDTH - STRING_LENGTH
done_move_left_Ruben:
    ret

move_right_Ruben:
    inc word [ruben_x]
    cmp word [ruben_x], SCREEN_WIDTH - STRING_LENGTH
    jle done_move_right_Ruben
    mov word [ruben_x], 0
done_move_right_Ruben:
    ret

clear_screen:
    mov ax, TEXT_MODE
    int 10h
    ret

random_position_Joseph:
    ;; Generar una posición X aleatoria dentro del rango de la pantalla para Joseph
    in al, 40h
    and al, 0x1F
    mov bl, SCREEN_WIDTH - STRING_LENGTH
    mul bl
    mov [joseph_x], al

    ;; Generar una posición Y aleatoria dentro del rango de la pantalla para Joseph
    in al, 40h
    and al, 0x1F
    mov bl, SCREEN_HEIGHT - 1
    mul bl
    mov [joseph_y], al
    ret

random_position_Ruben:
    ;; Generar una posición X aleatoria dentro del rango de la pantalla para Ruben
    in al, 40h
    and al, 0x1F
    mov bl, SCREEN_WIDTH - STRING_LENGTH
    mul bl
    mov [ruben_x], al

    ;; Generar una posición Y aleatoria dentro del rango de la pantalla para Ruben
    in al, 40h
    and al, 0x1F
    mov bl, SCREEN_HEIGHT - 1
    mul bl
    mov [ruben_y], al
    ret

salir_bootloader:
    ; Limpiar la pantalla antes de salir (opcional)
    mov ax, TEXT_MODE
    int 10h

    ; Detener la ejecución (bucle infinito)
    hlt
    jmp $

joseph_string db 'Joseph', 0
ruben_string db 'Ruben', 0

joseph_x dw 0
joseph_y dw 0
ruben_x dw 0
ruben_y dw 0

times 510-($-$$) db 0
dw 0xAA55
