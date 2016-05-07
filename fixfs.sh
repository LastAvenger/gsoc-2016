#!/usr/bin/sh

losetup --show -f -P $1
fsck.ext2 /dev/loop0p1 -fy
losetup -d /dev/loop0
