Hurd Development Envirnment Setup
=================================

Ref: http://www.gnu.org/software/hurd/contributing.html#index4h2

- Qemu 2.5.0
- Host: Arch Linux
- KVM support

## Download Run Hurd on Qemu

    wget https://people.debian.org/~sthibault/hurd-i386/debian-hurd.img.tar.gz
    tar xvf debian-hurd.img.tar.gz -C .
    # rename it as "debian-hurd.img"
    qemu-system-i386 -enable-kvm -m 1G  \
    -drive cache=writeback,file=debian-hurd.img,format=raw

## Build hurd

    autoreconf -i && ./configure && make

## Build glibc

    mkdir build
    ../glibc/configure --prefix=/usr
    make


## Attach to Hurd via SSH

`openssh-server` is pre-installed in the aboved image.

Create a virtual Network Interface Card (NIC) and connect to VLAN0,
redirect incoming TCP connections to the host port 22 to the guest port 5555:

    qemu-system-i386 -enable-kvm  -m 1G                         \
        -drive cache=writeback,file=debian-hurd.img,format=raw  \
        -net nic -net user,hostfwd=tcp::5555-:22

Then generate a pair of key, copy the public key to the guest using `scp`.

> NOTE: By default, the SSH server denies password-based login for root, so you should
>
> - set root password
> - add a user
> - config sudoer

> NOTE: attributes of `.ssh` should be `700`, `authorized_keys` should be `0600`

Use this command start up hurd and connect to it: (run `./run.sh`)

    qemu-system-i386 -enable-kvm  -m 1G                         \
        -drive cache=writeback,file=debian-hurd.img,format=raw  \
        -net nic -net user,hostfwd=tcp::5555-:22                \
        -display none & sleep 3 && ssh -p 5555 la@localhost

# Solution

## Error "Login incorrect"

firstly, try `fsck` on root file system and other file system.

    losetup -f -P ./debian-hurd.img
    e2fsck /dev/loop0p1 # maybe
    losetup -d /dev/loop0

if not, try boot hurd with kernel parameter "init=/bin/bash",

> 15:15:01< diegonc> LastAvengers: if you still have the "Login incorrect" message, sometime ago I had to boot with 'init=/bin/bash' in the kernel command-line and run 'dpkg-reconfigure hurd && reboot-hurd' in the shell to fix it (plain reboot didn't seem to work there); I'm not sure if that's still necessary, though  
> 15:17:06< LastAvengers> diegonc: how to pass kernel parameter to hurd?  
> 15:20:03< DusXMT> LastAvengers: The same way as on Linux, 'e' on the Grub entry, add init=/bin/bash to the 'multiboot /path/to/gnumach.gz ....', and ctrl+x (or at least that's what I'd think)

> 15:35:33< phant0mas> LastAvengers: retry and tell us step by step what you did and what went wrong  
> 15:36:14< phant0mas> similar things may happen all the time, you will have to learn to save the system :-)  
> 15:37:04< LastAvengers> after boot with init=/bin/bash, it say: hd0s1 FILESYSTEM NOT UMOUNTED CLEANLY  
> 15:37:30< phant0mas> LastAvengers:  did you get a shell?  
> 15:37:38< LastAvengers> yes.  
> 15:37:42< phant0mas> run fsck -y  
> 15:38:32< phant0mas> wait for fsck to finish and then run  fsysopts / --writable  
> 15:38:53< phant0mas> to remount the root partition as rw  
> 15:39:05< phant0mas> and then you can run dpkg-reconfigure hurd  
> 15:39:20< LastAvengers> can't check if fs is mounted due to missing mtab file while determining whether /dev/hd0s1 is mounted.  
> 15:39:31< LastAvengers> ^ fsck -y output  
> 15:40:09< LastAvengers> and Unknown code P 6 while trying to open /dev/hd1s1 <- the image for my /home  
> 15:40:59< braunr> hd0s1  
> 15:43:09< LastAvengers> phant0mas: dpkg-reconfigure completed.  
> 15:43:13< LastAvengers> then reboot?  
> 15:45:41< braunr> yes

> 16:10:29< LastAvengers> braunr: stop at "start ext2fs: Hurd server bootstarp: ext2fs[device: hd0s1] exec"  
> 16:14:56< braunr> retry, this is a rare race

As described above:

    # after get a shell
    fsck -y
    fsysopts / --writable
    mount -o remount,rw /dev/hd0s1 /
    dpkg-reconfigure hurd
    reboot-hurd

## Error "ext2fs: disk_cache_init: Block size 1024 != vm_page_size 4096"

Use `mkfs.ext2 -b 4096` to format your image.

## External library

> 10:50:25< teythoon> i tend to do (from my hurd build dir): settrans -a t /usr/bin/env LD_LIBRARY_PATH=$(pwd)/lib trans/hello
