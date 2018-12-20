
all : main

main : main.c Makefile
	gcc -o main main.c -lX11 -no-pie -fno-plt -O1 -std=gnu11 -nostartfiles -nostdlib
	strip main
	strip -R .note -R .comment -R .eh_frame -R .eh_frame_hdr -R .note.gnu.build-id -R .got -R .got.plt -R .gnu.version -R .rela.dyn -R .shstrtab -R .gnu.hash main
	#remove section header
	/home/blackle/Code/Projects/section-stripper/section-stripper.py main
	# mv main.tmp main
	# truncate --size=-32 main
	#clear out useless bits
	sed -i 's/_edata/\x00\x00\x00\x00\x00\x00/g' main;
	sed -i 's/__bss_start/\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00/g' main;
	sed -i 's/_end/\x00\x00\x00\x00/g' main;
	#clear out parts referring to section header
	#e_shoff
	# dd if=/dev/zero of=main bs=1 seek=40 count=8 conv=notrunc
	# #e_shentsize
	# dd if=/dev/zero of=main bs=1 seek=58 count=2 conv=notrunc
	# #e_shnum
	# dd if=/dev/zero of=main bs=1 seek=60 count=2 conv=notrunc
	# #e_shstrndx
	# dd if=/dev/zero of=main bs=1 seek=62 count=2 conv=notrunc
	#put in my name do not steal
	# printf 'blackle' | dd of=main bs=1 seek=8 count=7 conv=notrunc
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

main_mini : main.xz ~/Downloads/vondehi/vondehi
	cat ~/Downloads/vondehi/vondehi main.xz > main_mini
	chmod +x main_mini
	wc -c main_mini
