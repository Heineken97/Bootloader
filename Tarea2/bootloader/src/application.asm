use16
org 0x8000

SCREEN_WIDTH equ 80      ; Ancho en caracteres del modo texto (80 columnas)
SCREEN_HEIGHT equ 25     ; Alto en líneas de texto del modo texto (25 filas)
VIDEO_MEMORY equ 0A000h  ; Memoria de video VGA
TEXT_MODE equ 03h        ; Modo de texto 80x25
STRING_LENGTH equ 15     ; Longitud del string "Joseph y Ruben" (14 caracteres + 1 terminador nulo)
CHAR_WIDTH equ 8
CHAR_HEIGHT equ 16

mov ax, TEXT_MODE
int 10h                 ; Configurar el modo de texto 80x25

call random_position
call write_string_Joseph_Ruben

jmp main_loop

write_string_Joseph_Ruben:
    mov si, joseph_ruben_string
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

main_loop:
    call check_key_press
    jmp main_loop

check_key_press:
    mov ah, 01h          ; Verificar si hay una tecla presionada
    int 16h
    jz no_key            ; Si no hay tecla presionada, saltar

    mov ah, 00h          ; Obtener la tecla presionada
    int 16h

    cmp al, 'w'          ; Si es 'W' (arriba)
    je move_up
    cmp al, 's'          ; Si es 'S' (abajo)
    je move_down
    cmp al, 'a'          ; Si es 'A' (izquierda)
    je move_left
    cmp al, 'd'          ; Si es 'D' (derecha)
    je move_right
    cmp al, 'q'          ; Si es 'Q' (salir)
    je quit_program
    cmp al, 'r'          ; Si es 'R' (reset)
    je reset_program
no_key:
    ret

move_up:
    cmp word [position_x], SCREEN_WIDTH  ; Si ya está en la primera fila, no se mueve
    jl no_move_up
    sub word [position_x], SCREEN_WIDTH  ; Restar SCREEN_WIDTH para simular movimiento de una fila arriba
no_move_up:
    call clear_screen
    call write_string_Joseph_Ruben
    ret

move_down:
    cmp word [position_x], (SCREEN_HEIGHT - 1) * SCREEN_WIDTH  ; Asegurarse de no salir del límite inferior
    jge no_move_down
    add word [position_x], SCREEN_WIDTH  ; Sumar SCREEN_WIDTH para simular movimiento de una fila abajo
no_move_down:
    call clear_screen
    call write_string_Joseph_Ruben
    ret

move_left:
    cmp word [position_x], 0    ; Si ya está en la columna izquierda, no se mueve
    je no_move_left
    dec word [position_x]       ; Decrementa X (mueve hacia la izquierda)
no_move_left:
    call clear_screen
    call write_string_Joseph_Ruben
    ret

move_right:
    cmp word [position_x], SCREEN_WIDTH * SCREEN_HEIGHT - STRING_LENGTH  ; Corregido el límite de X para respetar el ancho del texto
    je no_move_right
    inc word [position_x]       ; Incrementa X (mueve hacia la derecha)
no_move_right:
    call clear_screen
    call write_string_Joseph_Ruben
    ret

clear_screen:
    mov ax, TEXT_MODE
    int 10h
    ret

random_position:
    ;; Generar una posición X aleatoria dentro del rango de la pantalla
    in al, 40h
    and al, 0x1F
    mov bl, SCREEN_WIDTH - STRING_LENGTH
    mul bl
    mov [position_x], al

    ;; Generar una posición Y aleatoria dentro del rango de la pantalla
    in al, 40h
    and al, 0x1F
    mov bl, SCREEN_HEIGHT - 1
    mul bl
    mov [position_y], al
    ret

quit_program:
    call clear_screen_black      ; Limpiar la pantalla con color negro
    jmp halt_forever             ; Detener el programa con un bucle infinito

clear_screen_black:
    mov ax, 03h                  ; Volver al modo de texto 80x25 para limpiar correctamente
    int 10h                      ; Configurar modo de texto 80x25 (negro por defecto)
    ret

halt_forever:
    cli                          ; Desactivar interrupciones
.halt_loop:
    hlt                          ; Halt para detener la CPU indefinidamente
    jmp .halt_loop                ; Bucle infinito
    ret

reset_program:
    int 19h                      ; Interrupción de BIOS para reiniciar el sistema
    ret

joseph_ruben_string db 'Joseph y Ruben', 0

position_x dw 0
position_y dw 0

times 510-($-$$) db 0
dw 0xAA55
