nasm = nasm

default:./target/image.img

run:default
	qemu-system-i386 -fda ./target/image.img

debug:default
	qemu-system-i386 -fda ./target/image.img -s -S -m 32 &
	gdb -x ./script/gdb.cmd

./target/image.img:./target/boot.bin ./target/loader.bin
	cp ./history/resources/emptyfloppy.img ./target/image.img
	dd if=./target/boot.bin of=./target/image.img bs=512 count=1 conv=notrunc
	sudo mkdir -p /mnt/img
	sudo mount -o rw ./target/image.img /mnt/img
	sudo cp ./target/loader.bin /mnt/img/loader.bin
	sudo cp ./target/boot.bin /mnt/img/kernel.bin
	# -l option for lazy umount
	sudo umount /mnt/img -l
	sudo rm -rf /mnt/img
	
./target/boot.bin:./src/asm/*
	$(nasm) ./src/asm/boot.asm -f bin -o ./target/boot.bin -i ./src/asm/ -l ./list/boot.list

./target/loader.bin:./src/asm/*	
	$(nasm) ./src/asm/loader.asm -f bin -o ./target/loader.bin -i ./src/asm/ -l  ./list/loader.list

