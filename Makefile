default: build

arch ?= x86_64
kernel := build/kernel-$(arch).bin
iso := build/os-$(arch).iso
target ?= $(arch)-unknown-linux-gnu

grub_cfg := src/arch/$(arch)/grub.cfg
linker := src/arch/$(arch)/linker.ld
rust_os := target/$(target)/debug/libosxidation.a

asm_src_files := $(wildcard src/arch/$(arch)/*.asm)
asm_obj_files := $(patsubst src/arch/$(arch)/%.asm, \
	build/arch/$(arch)/%.o, $(asm_src_files))

.PHONY: clean

all: $(kernel)

clean:
	rm -rf build 
	rm -rf target
	rm -rf $(kernel)
	rm -rf $(iso)

run: $(iso) 
	qemu-system-x86_64 -cdrom $(iso)

iso: $(iso)

$(iso): $(kernel) $(grub_cfg) 
	mkdir -p build/isofiles/boot/grub
	cp $(grub_cfg) build/isofiles/boot/grub
	cp $(kernel) build/isofiles/boot/kernel.bin
	grub-mkrescue -o $(iso) build/isofiles

$(kernel): cargo $(rust_os) $(asm_obj_files) $(linker) 
	ld -n -T $(linker) -o $(kernel) $(asm_obj_files) $(rust_os) 

cargo:
	cargo rustc --target $(target)

build/arch/$(arch)/%.o: src/arch/$(arch)/%.asm
	mkdir -p $(shell dirname $@)
	nasm -f elf64 $< -o $@
