default:

d2:./src/d2/ipl.asm
	mkdir -p ./target/d2
	nasm ./src/d2/ipl.asm -f bin -o ./target/d2/ipl.bin -l ./target/d2/ipl.list
	cp ./resources/emptyfloppy.img ./target/d2/image.img
	dd if=./target/d2/ipl.bin of=./target/d2/image.img bs=512 count=1 conv=notrunc
	cp ./target/d2/image.img ./target/image.img

d3:./src/d3/ipl.asm
	mkdir -p ./target/d3
	nasm ./src/d3/ipl.asm -f bin -o ./target/d3/ipl.bin -l ./target/d3/ipl.list
	cp ./resources/emptyfloppy.img ./target/d3/image.img
	dd if=./target/d3/ipl.bin of=./target/d3/image.img bs=512 count=1 conv=notrunc
	cp ./target/d3/image.img ./target/image.img

run:
	qemu-system-i386 ./target/image.img
