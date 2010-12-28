#!/bin/bash

IMAPTEST=/root/imaptest-20100922/src/imaptest
MBOX=/root/dovecot-crlf
USERFILE=/etc/dovecot/userlist
OUTDIR=/root/benches-imaptest/glusterfs-fuse
CREATE_DIR_SCRIPT=/root/c.sh


for c in $(seq -w 10 10 500); do

	echo "[*] cleaning dovecot log files"
	> /var/log/dovecot.log
	> /var/log/dovecot-info.log

	echo "[*] Umounting /mnt/dovecot"
	fusermount -u /mnt/dovecot
	sleep 2

	echo "[*] Mounting GlusterFS..."
	mount -t glusterfs /etc/glusterfs/glusterfs.vol /mnt/dovecot
	sleep 2

	echo "[*] Removing index directories: rm -rf /mnt/localstorage/*"
	rm -rf /mnt/localstorage/*
	sleep 2

#	echo "[*] Creating all the users' directories (/mnt/dovecot/test* and /mnt/localstorage/test*)"
#	(for i in $(seq -w 500); do
#	echo test$i
#	done) | xargs -n1 -P 50 $CREATE_DIR_SCRIPT
#	sleep 2

	echo "[*] Chown-ing doveusers:doveusers /mnt/localstorage"
	chmod 777 /mnt/localstorage
	chown -R doveusers:doveusers /mnt/localstorage/
	sleep 2

	echo "[*] Running imaptest for $c clients"
	$IMAPTEST clients=$c secs=60 seed=4242 mbox=$MBOX no_tracking userfile=$USERFILE pass=pass >> $OUTDIR/bench_imaptest_glusterfs_fuse_${c}_clients.txt
	sleep 2
done
