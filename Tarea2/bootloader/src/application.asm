use16                	      ; Utilizar código de 16 bits
org 8000            	      ; Comenzar en la dirección 0x8000

;; CONSTANTES
VIDMEM       equ 0B800h       ; Ubicación de la memoria de video en modo texto
SCREENW      equ 80           ; Ancho de la pantalla (80 caracteres)
SCREENH      equ 25           ; Altura de la pantalla (25 líneas)
NAME1        db 'Nombre1', 0  ; Primer nombre
NAME2        db 'Nombre2', 0  ; Segundo nombre

;; VARIABLES
name1X:      dw 0             ; Posición X inicial de NAME1
name1Y:      dw 0             ; Posición Y inicial de NAME1
name2X:      dw 0             ; Posición X inicial de NAME2
name2Y:      dw 0             ; Posición Y inicial de NAME2

;; LÓGICA
setup:
	; Configurar modo de video
	mov ax, 3			; Modo de texto 80x25
	int 10h

	; Configurar memoria de video
	mov ax, VIDMEM
	mov es, ax      		; ES apunta a la memoria de video

	; Generar posiciones aleatorias para ambos nombres
	call random_position1
	call random_position2

	; Dibujar los nombres
	call draw_names

main_loop:
	; Obtener entrada del teclado
	mov ah, 0			; Función BIOS para leer tecla presionada
	int 16h
	; Detectar flechas
	cmp ah, 48h              ; Flecha arriba
	je rotate_up
	cmp ah, 50h              ; Flecha abajo
	je rotate_down
	cmp ah, 4Bh              ; Flecha izquierda
	je rotate_left
	cmp ah, 4Dh              ; Flecha derecha
	je rotate_right
	jmp main_loop

rotate_left:
	call clear_screen
	call rotate_90_left
	call draw_names
	jmp main_loop

rotate_right:
	call clear_screen
	call rotate_90_right
	call draw_names
	jmp main_loop

rotate_up:
	call clear_screen
	call rotate_180_up
	call draw_names
	jmp main_loop

rotate_down:
	call clear_screen
	call rotate_180_down
	call draw_names
	jmp main_loop

clear_screen:
	mov ax, 0600h            ; Función para limpiar pantalla
	mov bh, 01h              ; Color de fondo azul
	mov cx, 0                ; Esquina superior izquierda
	mov dx, 184Fh            ; Esquina inferior derecha
	int 10h
	ret

draw_names:
	; Dibujar NAME1
	mov ax, [name1Y]
	mov cx, SCREENW
	mul cx
	add ax, [name1X]
	mov di, ax
	mov si, NAME1
	mov ah, 0Fh              ; Color de texto blanco sobre fondo azul
	call draw_name

	; Dibujar NAME2 en una posición distinta
	mov ax, [name2Y]
	mov cx, SCREENW
	mul cx
	add ax, [name2X]
	mov di, ax
	mov si, NAME2
	mov ah, 0Fh              ; Color de texto blanco sobre fondo azul
	call draw_name
	ret

draw_name:
	mov ah, 0Ah              ; Atributo de color
.next_char:
	lodsb                    ; Cargar carácter
	cmp al, 0
	je .done                 ; Si es el final del nombre, salir
	mov es:[di], al          ; Escribir carácter
	inc di
	mov es:[di], ah          ; Escribir atributo
	inc di
	jmp .next_char
.done:
	ret

random_position1:
	; Generar posiciones X e Y aleatorias para NAME1
	call random_number
	mov dx, ax
	xor dx, dx
	mov cx, SCREENW-10
	div cx
	mov [name1X], dx

	call random_number
	mov dx, ax
	xor dx, dx
	mov cx, SCREENH-1
	div cx
	mov [name1Y], dx
	ret

random_position2:
	; Generar posiciones X e Y aleatorias para NAME2
	call random_number
	mov dx, ax
	xor dx, dx
	mov cx, SCREENW-10
	div cx
	mov [name2X], dx

	call random_number
	mov dx, ax
	xor dx, dx
	mov cx, SCREENH-1
	div cx
	mov [name2Y], dx
	ret

random_number:
	mov ah, 00h
	int 1Ah
	mov ax, dx
	ret

rotate_90_left:
	; Intercambiar las posiciones X y Y de ambos nombres
	mov ax, [name1X]
	mov bx, [name1Y]
	mov [name1X], bx
	mov [name1Y], ax

	mov ax, [name2X]
	mov bx, [name2Y]
	mov [name2X], bx
	mov [name2Y], ax
	ret

rotate_90_right:
	; Intercambiar las posiciones X y Y de ambos nombres
	mov ax, [name1X]
	mov bx, [name1Y]
	mov [name1X], bx
	mov [name1Y], ax

	mov ax, [name2X]
	mov bx, [name2Y]
	mov [name2X], bx
	mov [name2Y], ax
	ret

rotate_180_up:
	mov ax, SCREENH-1
	sub ax, [name1Y]
	mov [name1Y], ax
	sub ax, [name2Y]
	mov [name2Y], ax
	ret

rotate_180_down:
	mov ax, SCREENH-1
	sub ax, [name1Y]
	mov [name1Y], ax
	sub ax, [name2Y]
	mov [name2Y], ax
	ret

times 510-($-$$) db 0
dw 0AA55h       ; Firma del sector de arranque
