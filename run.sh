#!/usr/bin/sh
qemu-system-i386 -enable-kvm  -m 512 -drive cache=writeback,file=debian-hurd.img,format=raw
