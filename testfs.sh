TEST_NODE=~/test
EXT2FS_PATH=~/hurd/ext2fs

load() {
    mv $EXT2FS_PATH/ext2fs $EXT2FS_PATH/_ext2fs
    sudo settrans -a $TEST_NODE $EXT2FS_PATH/_ext2fs /dev/hd2
}

unload() {
    sudo settrans -g $TEST_NODE
}

attach () {
    sudo gdb $EXT2FS_PATH/_ext2fs --pid $(pidof _ext2fs)
}
