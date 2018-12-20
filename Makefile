
all : trans_flag

.PHONY: packer

packer:
	cd vondehi; nasm -fbin -o vondehi vondehi.asm

main : main.c Makefile
	gcc -o main main.c -lX11 -no-pie -fno-plt -O1 -std=gnu11 -nostartfiles -nostdlib
	strip main
	strip -R .note -R .comment -R .eh_frame -R .eh_frame_hdr -R .note.gnu.build-id -R .got -R .got.plt -R .gnu.version -R .rela.dyn -R .shstrtab -R .gnu.hash main
	#remove section header
	./Section-Header-Stripper/section-stripper.py main
	#clear out useless bits
	sed -i 's/_edata/\x00\x00\x00\x00\x00\x00/g' main;
	sed -i 's/__bss_start/\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00/g' main;
	sed -i 's/_end/\x00\x00\x00\x00/g' main;
	wc -c main
	chmod +x main

main.gz : main Makefile
	-rm main.gz
	zopfli --gzip main
	wc -c main.gz

main.xz : main Makefile
	-rm main.xz
	lzma --format=lzma -9 --extreme --lzma1=preset=9,lc=0,lp=0,pb=0,nice=64,depth=16,dict=16384 --keep --stdout main > main.xz
	wc -c main.xz

trans_flag : main.xz packer
	cat ./vondehi/vondehi main.xz > trans_flag
	chmod +x trans_flag
	wc -c trans_flag
