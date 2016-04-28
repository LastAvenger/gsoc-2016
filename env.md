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
