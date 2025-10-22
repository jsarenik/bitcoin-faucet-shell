#!/bin/sh

cd ~/.bitcoin/signet

$HOME/bin/blocknotify.sh $1 -t

rm -rf wallets/wosh-default/*last* /tmp/faucet/signetlimit /tmp/signetfaucet
WHERE=/tmp/faucet
busybox find $WHERE/.limit -mindepth 1 -type d -delete

ut.sh signet
gmm=$(gmm-gent.sh)
nm=$(nextmin.sh | awk '{print $3}')
test $nm -lt $gmm && echo $nm || echo $gmm | safecat.sh /tmp/gmm-signet
all-sums.sh signet
gen-sfb.sh

true
