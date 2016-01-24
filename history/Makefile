default:

d2:./src/d2/ipl.asm
	nasm ./src/d2/ipl.asm -f bin -o ./target/d2/ipl.bin -l ./target/d2/ipl.list
	cp ./resources/emptyfloppy.img ./target/d2/image.img
	dd if=./target/d2/ipl.bin of=./target/d2/image.img bs=512 count=1 conv=notrunc
	cp ./target/d2/image.img ./target/image.img
run:
	qemu-system-i386 ./target/d2/image.img
