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

simplereplnn.sh

true
