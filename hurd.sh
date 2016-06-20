# Script used in hurd

# load/unload/debug custom ext2fs
# use the staticlly-linked version

EXT2FS_PATH=~/hurd/ext2fs
TEST_NODE=~/test
TEST_IMG=~/ext2.img

load() {
    mv $EXT2FS_PATH/ext2fs.static $EXT2FS_PATH/_ext2fs
    settrans -a $TEST_NODE $EXT2FS_PATH/_ext2fs $TEST_IMG
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
    sudo settrans -a $TEST_NODE/test /hurd/hello -c "Gentleness is deadly"
    cat test/test
    sudo settrans -g $TEST_NODE/test
    unload
}

xattr () {
    load
    chmod 777 test/test
    unload
}
