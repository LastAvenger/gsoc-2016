#!/usr/bin/sh
# ./sync -c|-i [g2h h2g]
# -c: rsync code from guest to host ($GUEST_DEST -> $HOST_DEST)
# -i: rsync a ext2 image between guest and host ($GUEST_DEST <-> $HOST_DEST)

GUSET_DEST="\."
HOST_DEST="/home/la/git/gsoc-2016"

remote_cmd() {
    ssh -p 5555 -t la@localhost $1
}

if [[ "$1" == "-c" || -z "$1" ]]; then
    rsync -avzP $HOST_DEST/hurd la@localhost:$GUEST_DEST
    remote_cmd "cd ~/hurd/ext2fs; rm xattr.o; make"
fi

if [[ "$1" == "-i" ]]; then
    if [[ "$2" == "g2h" ]]; then
        rsync -avzP la@localhost:"\./ext2.img" $HOST_DEST
    elif [[ "$2" == "h2g" ]]; then
        rsync -avzP $HOST_DEST/ext2.img la@localhost:$GUSET_DEST
    fi
fi
