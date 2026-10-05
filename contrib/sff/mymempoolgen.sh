#!/bin/sh

lock=/tmp/mmg
mkdir $lock || exit 1

myexit() {
  rmdir $lock 2>/dev/null
  exit $1
}

HOME=/home/nsm
. $HOME/.profile
export TZ=UTC
d=/dev/shm
read -r ver < $d/half/uname

{
cat <<EOF
# $ver
# /dev/shm and /tmp are tmpfs
# as user, nsm here:
#   touch /dev/shm/mempool.dat.new
# as root:
#   cd /home/nsm/.bitcoin
#   mount -o rw,bind /dev/shm/mempool.dat.new mempool.dat.new
# everything else here that follows
# is run as an unprivileged user
EOF
set -x
date -u
bitcoind -version | head -1
bitcoin-cli echo hello | grep . || myexit 1
mountpoint $HOME/.bitcoin/mempool.dat.new || myexit 1

bitcoin-cli getmempoolinfo | nicecat.sh /tmp/gmi-main.json

: following is getrawmempool, just shortened
grm.sh | safecat.sh /dev/shm/mymempool.txt
#time sh -c "bitcoin-cli savemempool 2>/dev/null"
: Following non-zero exit is intended.
: On bitcoind side it looks like this:
:   Failed to dump mempool: Rename failed. Continuing anyway.
time bitcoin-cli savemempool

f=$d/mempool.dat.new
t=$d/mempool.dat.tmp
cp $f $t
#ln -f $d/mempool.copy.old $d/mempool.copy.old2
#ln -f $d/mempool.copy $d/mempool.copy.old
: UNIX fixes this, file descriptor stays
: i n memory when used even after file was
: successfully unlinked from filesystem
: GNU is Not Unix anyway
mv $t $d/mempool.copy
ln -s $d/mempool.copy $d/mempool.copy.dat

cd $d
ls -ilh mempool.copy mempool.dat.new
cd $HOME/web/ln
ls -l mymempool*

date -u
} 2>&1 | nicecat.sh $d/mymempool.log

myexit
