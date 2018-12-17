export ARCH=arm
export CROSS_COMPILE=/opt/arm-buildroot/bin/arm-linux-

PWD=$(shell pwd)
OUT=${PWD}/out
CPUS=$(shell grep processor /proc/cpuinfo |wc -l)

rootfs:
	cd _rootfs; find . |cpio --quiet -H newc -o |gzip -9 -n >${PWD}/rootfs.cpio.gz

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
		-sd ./rootfs.ext2 \
		-append "root=/dev/mmcblk0 console=ttyAMA0 loglevel=8" 

dbg:
	qemu-system-arm -M vexpress-a9 -m 1024M -nographic \
		-kernel ./zImage \
		-dtb vexpress-v2p-ca9.dtb \
		-sd ./rootfs.ext2 \
		-append "root=/dev/mmcblk0 console=ttyAMA0 loglevel=8" \
		-s -S
gdb:
	${CROSS_COMPILE}gdb -q -s ${OUT}/vmlinux -d linux -ex "target remote localhost:1234"
clean:
	-rm -rf zImage *.dtb out
