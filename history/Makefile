default:

d2:./target/d2/image.img

./target/d2/image.img:./src/d2/ipl.asm
	mkdir -p ./target/d2
	nasm ./src/d2/ipl.asm -f bin -o ./target/d2/ipl.bin -l ./target/d2/ipl.list
	cp ./resources/emptyfloppy.img ./target/d2/image.img
	dd if=./target/d2/ipl.bin of=./target/d2/image.img bs=512 count=1 conv=notrunc

d2run:d2
	qemu-system-i386 -fda ./target/d2/image.img

d3:./target/d3/image.img
	
./target/d3/image.img:./src/d3/ipl.asm ./src/d3/app.asm ./src/d3/print.asm
	mkdir -p ./target/d3
	nasm ./src/d3/ipl.asm -f bin -o ./target/d3/ipl.bin -l ./target/d3/ipl.list
	nasm ./src/d3/app.asm -f bin -o ./target/d3/app.sys -l ./target/d3/app.list -i ./src/d3/
	cp ./resources/emptyfloppy.img ./target/d3/image.img
	dd if=./target/d3/ipl.bin of=./target/d3/image.img bs=512 count=1 conv=notrunc
	sudo mkdir -p /mnt/img
	sudo mount -o rw ./target/d3/image.img /mnt/img
	sudo cp ./target/d3/app.sys /mnt/img/
	# -l option for lazy umount
	sudo umount /mnt/img -l
	sudo rm -rf /mnt/img

d3run:d3
	qemu-system-i386 -fda ./target/d3/image.img

d3debug:d3
	qemu-system-i386 -fda ./target/d3/image.img -S -monitor stdio

# this is used to show how elf works
d4elf: ./target/d4/foobar

./target/d4/foobar: ./src/d4/foo.asm ./src/d4/bar.c
	mkdir -p ./target/d4
	nasm ./src/d4/foo.asm -f elf -o ./target/d4/foo.o
	gcc -m32 -c ./src/d4/bar.c -o ./target/d4/bar.o
	ld -m elf_i386 ./target/d4/foo.o ./target/d4/bar.o -o ./target/d4/foobar
