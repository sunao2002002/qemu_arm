# qemu_arm
通过qemu搭建ARM模拟环境。
## 环境搭建
```
sudo apt-get install qemu-system-arm gcc-arm-linu-gnueabi make binutils
```
## 编译
```
make defconfig kernel
```
## 修改配置
```
make kconfig

```
do some change 
```
make kernel
```
## 根文件系统
```
sudo make rootfs
```
由于生成文件系统时需要执行mount/umount等特权指令，所以需要sudo执行。
##  运行
```
make run
```
提示登陆时，输入用户名 root，不需要密码
## gdb调试
打开两个terminal或者用tmux等工具开两个panel。
第一个运行“make dbg”，第二个窗口运行“make gdb”

## clean
运行 “make clean”