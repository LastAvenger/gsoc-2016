EXT2FS_PATH=~/hurd/ext2fs
TEST_NODE=~/test
TEST_IMG=~/ext2.img

load() {
    mv $EXT2FS_PATH/ext2fs $EXT2FS_PATH/_ext2fs
    settrans -a $TEST_NODE $EXT2FS_PATH/_ext2fs $TEST_IMG
}

unload() {
    settrans -g $TEST_NODE
}

attach () {
    gdb $EXT2FS_PATH/_ext2fs --pid $(pidof _ext2fs)
}
