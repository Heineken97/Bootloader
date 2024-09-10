use16                	      ; Utilizar código de 16 bits
org 8000h            	      ; Comenzar en la dirección 0x8000
;; CONSTANTES-
VIDMEM       equ 0B800h       ; Ubicación de la memoria de video en modo texto
SCREENW      equ 80           ; Ancho de la pantalla (80 caracteres)
SCREENH      equ 25           ; Altura de la pantalla (25 líneas)
NAME1        db 'Nombre1', 0  ; Primer nombre
NAME2        db 'Nombre2', 0  ; Segundo nombre
;; VARIABLES-
nameX:       dw 0             ; Posición X inicial de nombre1 (se calculará aleatoriamente)
nameY:       dw 0             ; Posición Y inicial de nombre2 (se calculará aleatoriamente)
;; LÓGICA-
setup:
	; Configurar modo de video
	mov ax, 3			; Modo de texto 80x25
	int 10h
	; Configurar memoria de video
	mov ax, VIDMEM
	mov es, ax      		; ES apunta a la memoria de video
	; Generar posiciones aleatorias
	call random_position
	; Dibujar los nombres
	call draw_names
main_loop:
	; Obtener entrada del teclado
	mov ah, 0			; Función BIOS para leer tecla presionada
	int 16h; Esperar a que se presione una tecla
	; Detectar flechas
	cmp ah, 48h              ; Flecha arriba
	je rotate_up
	cmp ah, 50h              ; Flecha abajo
	je rotate_down
	cmp ah, 4Bh              ; Flecha izquierda
	je rotate_left
	cmp ah, 4Dh              ; Flecha derecha
	je rotate_right
	jmp main_loop            ; Volver a esperar otra tecla

rotate_left:
	call clear_screen
	; Rotar nombres 90 grados a la izquierda sobre el eje vertical
	call rotate_90_left
    	call draw_names
    	jmp main_loop
rotate_right:
	 call clear_screen
	; Rotar nombres 90 grados a la derecha sobre el eje vertical
	call rotate_90_right
	call draw_names
	jmp main_loop
rotate_up:
	call clear_screen
	; Rotar nombres 180 grados hacia arriba sobre el eje horizontal
	call rotate_180_up
	call draw_names
	jmp main_loop
rotate_down:
	call clear_screen
	; Rotar nombres 180 grados hacia abajo sobre el eje horizontal
	call rotate_180_down
	call draw_names
	jmp main_loop

clear_screen:
	; Limpiar pantalla
	mov ax, 0600h            ; Función para limpiar pantalla
	mov bh, 07h              ; Color de fondo
	mov cx, 0                ; Esquina superior izquierda
	mov dx, 184Fh            ; Esquina inferior derecha
	int 10h
	ret
draw_names:
	; Dibujar el primer nombre
	mov si, nameX
	mov di, nameY
	call draw_name
	add si, 10               ; Espacio entre los nombres
	; Dibujar el segundo nombre
	mov si, nameX
	add di, 2 * SCREENW      ; Mover a la siguiente línea (o cualquier otra posición deseada)
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

random_position:
	; Generar posiciones X e Y aleatorias dentro de la pantalla
	call random_number       ; Generar número aleatorio
    	mov dx, ax
    	xor dx, dx
    	mov cx, SCREENW-10       ; Ancho máximo menos longitud del nombre
    	div cx
    	mov [nameX], dx          ; Guardar la posición X aleatoria
	call random_number       ; Generar otro número aleatorio
	mov dx, ax
	xor dx, dx
	mov cx, SCREENH-1        ; Altura máxima
	div cx
	mov [nameY], dx          ; Guardar la posición Y aleatoria
	ret
random_number:
	; Generar un número aleatorio (16 bits)
	; Usar el temporizador del sistema para generar un valor pseudoaleatorio
    	mov ah, 00h
    	int 1Ah                  ; Llamar a BIOS: Leer reloj del sistema
    	mov ax, dx               ; Usar la parte baja del reloj como número aleatorio
    	ret

rotate_90_left:
	; Implementar lógica de rotación 90 grados a la izquierda sobre el eje vertical
	; Intercambiar las posiciones X y Y de los nombres
	mov ax, [nameX]
	mov bx, [nameY]
    	mov [nameX], bx
    	mov [nameY], ax
    	; Ajustar la posición para reflejar la rotación
    	sub word [nameX], 7       ; Corregido con tamaño de operación
    	ret
rotate_90_right:
	; Implementar lógica de rotación 90 grados a la derecha sobre el eje vertical
    	; Intercambiar las posiciones X y Y de los nombres
   	mov ax, [nameX]
    	mov bx, [nameY]
    	mov [nameX], bx
	mov [nameY], ax
	; Ajustar la posición para reflejar la rotación
	add word [nameX], 7       ; Corregido con tamaño de operación
	ret
rotate_180_up:
    	; Implementar lógica de rotación 180 grados hacia arriba sobre el eje horizontal
    	; Invertir las posiciones Y de los nombres
    	mov ax, SCREENH-1
    	sub ax, [nameY]
    	mov [nameY], ax
    	ret
rotate_180_down:
    	; Implementar lógica de rotación 180 grados hacia abajo sobre el eje horizontal
    	; Invertir las posiciones Y de los nombres
    	mov ax, SCREENH-1
    	sub ax, [nameY]
    	mov [nameY], ax
    	ret
times 510-($-$$) db 0
dw 0AA55h       ; Firma del sector de arranque
