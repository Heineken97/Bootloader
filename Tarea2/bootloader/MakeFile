all:
	nasm -f bin src/main.asm -o main.bin
	nasm -f bin src/application.asm -o application.bin
	cat main.bin application.bin > Applicacion_Bootloader
	rm *.bin
	mv Applicacion_Bootloader application.bin

clean:
	rm *.bin

run:
	qemu-system-i386 -drive format=raw,file=application.bin
