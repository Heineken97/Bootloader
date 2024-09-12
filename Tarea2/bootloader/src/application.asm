use16           ; Asegura que se use código de 16 bits
org 8000h       ; Comienza en 8000h

;; CONSTANTES =====================================================
SCREEN_WIDTH        equ 320     ; Ancho de pantalla en píxeles
SCREEN_HEIGHT       equ 200     ; Altura de pantalla en píxeles
VIDEO_MEMORY        equ 0A000h  ; Memoria de video VGA
SPRITE_SIZE         equ 16      ; Tamaño del sprite
SPRITE_WIDTH_PIXELS equ 16      ; Ancho del sprite en píxeles

;; Configurar el modo de video: Modo 13h VGA 320x200, 256 colores
mov ax, 0013h
int 10h

;; Configurar la memoria de video
mov ax, VIDEO_MEMORY
mov es, ax          ; ES -> A0000h (memoria de video)

;; Configurar el fondo azul =======================================
mov cx, SCREEN_WIDTH * SCREEN_HEIGHT
mov al, 1           ; Color azul
mov di, 0
fill_screen:
    stosb
    loop fill_screen

;; Generar posiciones aleatorias =================================
call random_position
mov cx, position_x
mov dx, position_y

;; Dibujar los dos cuadros =======================================
call dibujar_1
call random_position
mov cx, position_x
mov dx, position_y
call dibujar_2

jmp $

;; SUBRUTINAS =====================================================
;; Dibuja el primer cuadro en la pantalla
dibujar_1:
    ;; Definir el color del cuadro
    mov bl, 0x0F  ; Color blanco brillante

    ;; Dibujar el cuadro en la posición aleatoria
    call get_screen_position
    mov cx, SPRITE_SIZE
    call draw_large_sprite

    ret

;; Dibuja el segundo cuadro en la pantalla
dibujar_2:
    ;; Definir el color del cuadro
    mov bl, 0x0F  ; Color blanco brillante

    ;; Dibujar el cuadro en la posición aleatoria
    call get_screen_position
    mov cx, SPRITE_SIZE
    call draw_large_sprite

    ret

;; Dibuja un sprite grande en la pantalla
;; Los valores de entrada:
;;   AL = valor de Y
;;   AH = valor de X
;;   BL = color del sprite
draw_large_sprite:
    call get_screen_position  ; Obtener la posición en pantalla (en DI)
    mov cx, SPRITE_SIZE       ; Definir el tamaño del sprite

.next_line:
    push cx
    mov cx, SPRITE_WIDTH_PIXELS
.next_pixel:
    mov [es:di], bl       ; Dibujar el píxel
    inc di                ; Moverse al siguiente píxel en la misma fila
    loop .next_pixel      ; Repetir para toda la fila

    add di, SCREEN_WIDTH - SPRITE_WIDTH_PIXELS  ; Ir a la siguiente línea
    pop cx
    loop .next_line

    ret

;; Obtener la posición en pantalla
;; Entrada:
;;   AL = Y
;;   AH = X
get_screen_position:
    ;; Convertir la posición Y y X a un índice de pantalla
    mov dx, ax      ; Guardar los valores de Y y X
    cbw             ; Extender el signo de AL en AX
    imul di, ax, SCREEN_WIDTH  ; DI = Y * SCREEN_WIDTH
    mov al, dh      ; AL = X
    add di, ax      ; DI = Y * SCREEN_WIDTH + X (posición en pantalla)
    ret

;; Generar posición aleatoria =====================================
random_position:
    ;; Leer valor del puerto 40h para usar como base para aleatoriedad
    in al, 40h
    and al, 0x1F      ; Obtener 5 bits menos significativos
    mov bl, SCREEN_WIDTH - SPRITE_WIDTH_PIXELS
    mul bl             ; Multiplicar por el ancho máximo permitido para X
    mov [position_x], al

    ;; Leer otro valor del puerto 40h para la posición Y
    in al, 40h
    and al, 0x1F      ; Obtener 5 bits menos significativos
    mov bl, SCREEN_HEIGHT - SPRITE_SIZE
    mul bl             ; Multiplicar por la altura máxima permitida para Y
    mov [position_y], al

    ret

;; Datos ===========================================================
position_x dw 0      ; Posición X del primer rectángulo
position_y dw 0      ; Posición Y del primer rectángulo

;; Boot signature
times 510-($-$$) db 0
dw 0xAA55
