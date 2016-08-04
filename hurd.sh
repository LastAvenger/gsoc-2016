# Script used in hurd

# load/unload/debug custom ext2fs
# use the staticlly-linked version

EXT2FS_PATH=~/hurd/ext2fs
TEST_NODE=~/test
TEST_IMG=~/ext2.img

load() {
    cp $EXT2FS_PATH/ext2fs $EXT2FS_PATH/_ext2fs -v
    mkdir ~/hurd/libdiskfs/lib || true
    cp ~/hurd/libdiskfs/{,lib/}libdiskfs.so.0.3 -v

    settrans -a $TEST_NODE /usr/bin/env \
        LD_LIBRARY_PATH=$PWD/hurd/libdiskfs/lib  \
        $EXT2FS_PATH/_ext2fs $TEST_IMG
}

unload() {
    settrans -g $TEST_NODE
}

attach () {
    gdb $EXT2FS_PATH/_ext2fs --pid $(pidof _ext2fs)
}

# test xattr
# chmod is used as a interface of xattr code

trans () {
    load
    echo 'settrans -a: '
    sudo settrans -p -a $TEST_NODE/test /hurd/hello -c "Gentleness is deadly"
    echo 'showtrans: '
    showtrans $TEST_NODE/test
    echo 'settrans -g: '
    sudo settrans -p -g $TEST_NODE/test
    unload
}

xattr () {
    load
    chmod 777 test/tmp/test
    unload
}


hurdimg  (){
    dd if=/dev/zero of=$TEST_IMG bs=4M count=10
    sudo mkfs.ext2 -b 4096 $TEST_IMG

    settrans -a $TEST_NODE /hurd/ext2fs $TEST_IMG

    sudo mkdir $TEST_NODE/tmp
    sudo chmod 1777 $TEST_NODE/tmp
    sudo chown la:users $TEST_NODE/tmp
    touch $TEST_NODE/tmp/test
    settrans -p $TEST_NODE/tmp/test /hurd/hello -c "Gentleness is deadly"

    settrans -g $TEST_NODE
}
