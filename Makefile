.PHONY: sync imageg2h

# === ~/.ssh/config: ===
# Host localhost
#    Port 5555
#    IdentityFile ~/.ssh/hurd.private

MAKE = make
HOST = $(PWD)
GUEST = la@localhost
REMOTE_CMD =  ssh -tt $(GUEST) $1
IMG = ext2.img

# compile code
default:
	$(MAKE) sync
	$(REMOTE_CMD) "cd ~/hurd/ext2fs; rm xattr.o xattr_test.o; make"

# sync git repo from host -> guest
sync:
	rsync -avzP $(HOST)/hurd $(GUEST):

start:
	./run.sh

# sync test image from host -> guest
img2host:
	rsync -avzP $(GUEST):$(IMG) $(HOST)
	
img2guest:
	rsync -avzP $(HOST)/$(IMG) $(GUEST):

fsck:
	$(MAKE) img2host
	fsck.ext2 $(IMG)

mkfs:
	dd if=/dev/zero of=$(IMG) bs=4M count=10
	mkfs.ext2 -b 4096 $(IMG)

EXT2FS_CODE = ~/hurd/ext2fs
TEST_NODE = ~/test
TEST_IMG = ~/ext2.img

settrans:
	$(REMOTE_CMD) "cp $(EXT2FS_CODE)/{ext2fs.static,_ext2fs}; \
	    settrans -a $(TEST_NODE) $(EXT2FS_CODE)/_ext2fs $(TEST_IMG)"

unsettrans:
	$(REMOTE_CMD) "settrans -g $(TEST_IMG)"

testimg1:
	$(MAKE) mkfs
	mkdir -p tmp
	sudo mount $(IMG) ./tmp
	sudo touch ./tmp/test || true
	sudo setfattr -n user.key_123 -v val_123 ./tmp/test || true
	sudo setfattr -n user.key_456 -v val_456 ./tmp/test || true
	sudo umount ./tmp
	rm -rf ./tmp
	$(MAKE) img2guest

testimg2:
	$(MAKE) mkfs
	mkdir -p tmp
	sudo mount $(IMG) ./tmp
	sudo touch ./tmp/test || true
	sudo umount ./tmp
	rm -rf ./tmp
	$(MAKE) img2guest
