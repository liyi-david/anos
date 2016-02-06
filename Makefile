nasm = nasm
cc = gcc
ld = ld

export BXSHARE=/usr/share/bochs

default:./target/image.img

run:default
	qemu-system-i386 -fda ./target/image.img

debug:default
	bochsdbg -f ./script/bochsrc -q
	# gdb -x ./script/gdb.cmd
	#	qemu-system-i386 -fda ./target/image.img -s -S -m 32 &

./target/kernel.bin:./src/c/test.c
	# use -m32 to generate an i386 elf reallocatable object file
	$(cc) ./src/c/test.c -c -o ./target/test.o -m32
	$(nasm) ./src/asm/asmkernel.asm -f elf -o ./target/asmkernel.o
	$(ld) -m elf_i386 -s ./target/test.o ./target/asmkernel.o -o ./target/kernel.bin

./target/image.img:./target/boot.bin ./target/loader.bin ./target/kernel.bin
	cp ./history/resources/emptyfloppy.img ./target/image.img
	dd if=./target/boot.bin of=./target/image.img bs=512 count=1 conv=notrunc
	sudo mkdir -p /mnt/img
	sudo mount -o rw ./target/image.img /mnt/img
	sudo cp ./target/loader.bin /mnt/img/loader.bin
	sudo cp ./target/kernel.bin /mnt/img/kernel.bin
	# -l option for lazy umount
	sudo umount /mnt/img -l
	sudo rm -rf /mnt/img
	
./target/boot.bin:./src/asm/*
	$(nasm) ./src/asm/boot.asm -f bin -o ./target/boot.bin -i ./src/asm/ -l ./list/boot.list

./target/loader.bin:./src/asm/*	
	$(nasm) ./src/asm/loader.asm -f bin -o ./target/loader.bin -i ./src/asm/ -l  ./list/loader.list

clean:
	rm -rf ./target/*
