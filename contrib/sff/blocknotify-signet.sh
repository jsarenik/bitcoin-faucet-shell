#!/bin/sh

cd ~/.bitcoin/signet

$HOME/bin/blocknotify.sh $1 -t

rm -rf wallets/wosh-default/*last* /tmp/faucet/signetlimit /tmp/signetfaucet
WHERE=/tmp/faucet
/busybox/find $WHERE/.limit -mindepth 1 -type d -delete

ut.sh signet
all-sums.sh signet
gen-sfb.sh

mkdir -p /tmp/sffnewblock

log=/tmp/sfflastnew.log
tail=/tmp/sfflastnew-tail.log
ash -x ~/bin/simplereplnn.sh 2>&1 | safecat.sh $log
date -u | safeadd.sh $log
du -hs /dev/shm/wallets-signet/* | safeadd.sh $log
tail -n 25 $log | safecat.sh $tail

true
