#!/usr/bin/sh


for pid in $(pidof -x "$0"); do
    if [ $pid != $$ ]; then
        echo "$0: already running with PID $pid, attach to it"
        ssh -p 5555 la@localhost
        exit 0
    fi
done

[[ "$1" != "-g" ]] && arg="-display none"
qemu-system-i386 -enable-kvm  -m 1G                                 \
    -drive index=0,cache=writeback,file=debian-hurd.img,format=raw  \
    -drive index=1,cache=directsync,file=hd.img,format=raw          \
    -drive index=2,cache=directsync,file=test.img,format=raw        \
    -net nic -net user,hostfwd=tcp::5555-:22                        \
    $arg & sleep 3 && ssh -p 5555 la@localhost
