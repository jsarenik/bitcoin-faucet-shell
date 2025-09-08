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

rm -rf /tmp/sffnewblock
mkdir -p /tmp/sffnewblock

log=/tmp/sfflastnew.log
tail=/tmp/sfflastnew-tail.log
timeout 360 \
  ash -x ~/bin/simplereplnn.sh 2>&1 | safecat.sh $log
date -u | safeadd.sh $log
du -hs /dev/shm/wallets-signet/* | safeadd.sh $log
bitcoind -version | head -1 | safeadd.sh $log
(
  echo
  echo All current LN Anchor outputs seen by this node:
  echo "# txid vout amt conf safe"
  cd ~/.bitcoin/signet/wallets/lnanchor/
  list.sh
) | safeadd.sh $log
tail -n 25 $log | safecat.sh $tail

true
