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

ash -x ~/bin/simplereplnn.sh 2>&1 | safecat.sh /tmp/sfflastnew.log
tail /tmp/sfflastnew.log | safecat.sh /tmp/sfflastnew.log
date -u | safeadd.sh /tmp/sfflastnew.log

true
