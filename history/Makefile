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
	
./target/d3/image.img:./src/d3/ipl.asm ./src/d3/app.asm
	mkdir -p ./target/d3
	nasm ./src/d3/ipl.asm -f bin -o ./target/d3/ipl.bin -l ./target/d3/ipl.list
	nasm ./src/d3/app.asm -f bin -o ./target/d3/app.sys -l ./target/d3/app.list
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
