org 0x7c00
%define SECTOR_AMOUNT 0x4	; Cantidad de Sectores a leer
jmp short begin

welcome_message: db 'Bienvenido a nuestra Aplicacion, Presiona la tecla Espacio para iniciar'
.len equ ($-welcome_message)

begin:
	; Ocultar cursor de Interfaz
	mov ah, 1	; Cursor modo texto
	mov cx, 2607h	; CX = CH + CL: CH == Bit 5(2) -> Invisible && Scan Line Start(6), CL == Scan Line End(7)
	int 10h		; Interrupción 10h (BIOS de video)

	; Configurar memoria de Video
	mov ax, 0B800h	; Memoria de video comienza en dirección 0xB8000
	mov es, ax	; ES = Memoria video modo color texto (B8000)
	xor di, di	; ES:di = Puntero

	;; Limpiar pantalla
	mov ax, 2020h 	; AH = Fondo(2 = verde), AL = Espacio ASCII (0)
	mov cx, 80*25	; Número de caracteres en la pantalla
	rep stosw       ; Escribir todos los caracteres en Memoria de video
	xor di, di	; Reset puntero video

	;; Visualizar mensaje
	mov si, welcome_message
	mov cx, welcome_message.len
	call write_string

key_espacio:
	;; Esperar la Tecla "Space"
	mov ah, 0	; Función (0): Leer tecla presionada
	int 16h         ; Llamar a la interrupción del teclado BIOS
	cmp al, 20h     ; Verificar si la tecla presionada fue "Space"
	jne key_espacio	; Si no fue "Space", espera

	;; Limpiar pantalla antes de continuar
	mov ax, 2020h   ; AH = Fondo (2 = verde), AL = Espacio ASCII (0)
	mov cx, 80*25   ; Número de caracteres en la pantalla
	xor di, di      ; Resetear puntero video
	rep stosw       ; Escribir todos los caracteres Memoria de video

	;; Salta a la aplicacion
	jmp to_play

to_play:
	cli		; Desactivar interrupciones
	xor ax, ax
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov sp, 0x6ef0	; Configurar puntero
	sti		; Reactivar interrupciones
	mov ah, 0	; Funcion (0) para restablecer la unidad de disco
	int 0x13	; Interrupción 13h (BIOS de sectores de disco)

	mov bx, 0x8000	; Ubicacion de aplicacion
	mov al, SECTOR_AMOUNT
	mov ch, 0
	mov dh, 0
	mov cl, 2	; (2) Sector segunda parte del codigo
	mov ah, 2	; Funcion (2) para leer sectores
	int 0x13
	jmp 0x8000

;; Subrutina Escritura = Entradas: SI = address of string, CX = length of string
write_string:
	mov ah, 27h	    ; BG color (2 = verde) FG color (7 = light gray) 
	.loop:
		lodsb       ; mov AL, [DS:SI] incrementa SI
		stosw       ; Escribe caracter en Memoria (ES:DI)
	loop .loop  	    ; Decrementa CX; if CX != 0, jmp to label
	ret

times 510-($-$$) db 0
db 0x55
db 0xaa   ;numero magico
