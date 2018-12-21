export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabi-

PWD=$(shell pwd)
OUT=${PWD}/out
CPUS=$(shell grep processor /proc/cpuinfo |wc -l)

prepare:
	apt install -y gcc-arm-linux-gnueabi make binutils libncurse* qemu-system-arm mtd-utils

rootfs:
	-rm rootfs.img
	dd if=/dev/zero of=rootfs.img bs=4K count=32K
	mke2fs rootfs.img
	[ -d ${PWD}/mnt_tmp ] || mkdir -p ${PWD}/mnt_tmp
	mount -t ext2 -o loop rootfs.img ${PWD}/mnt_tmp
	cp -rf _rootfs/* ${PWD}/mnt_tmp
	sync
	umount ${PWD}/mnt_tmp
	chmod a+rw rootfs.img

defconfig:
	[ -d ${OUT} ] || mkdir -p ${OUT}
	make -C linux O=${OUT} vexpress_defconfig

kconfig:
	make -C linux O=${OUT} menuconfig

kernel:
	make -j${CPUS} -C linux O=${OUT} all
	cp ${OUT}/arch/arm/boot/zImage .
	cp ${OUT}/arch/arm/boot/dts/vexpress*.dtb .

run:
	qemu-system-arm -M vexpress-a9 -m 1024M -nographic \
		-kernel ./zImage \
		-dtb vexpress-v2p-ca9.dtb \
		-sd ./rootfs.img \
		-append "root=/dev/mmcblk0 console=ttyAMA0 loglevel=8" 

dbg:
	qemu-system-arm -M vexpress-a9 -m 1024M -nographic \
		-kernel ./zImage \
		-dtb vexpress-v2p-ca9.dtb \
		-sd ./rootfs.img \
		-append "root=/dev/mmcblk0 console=ttyAMA0 loglevel=8" \
		-s -S
gdb:
	${CROSS_COMPILE}gdb -q -s ${OUT}/vmlinux -d linux -ex "target remote localhost:1234"
clean:
	-rm -rf zImage *.dtb out rootfs.img mnt_tmp
