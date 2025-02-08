#!/bin/sh

cd ~/.bitcoin/signet

mkdir /tmp/locksff
$HOME/bin/blocknotify.sh $1 -t

rm -rf wallets/wosh-default/*last* /tmp/faucet/signetlimit /tmp/signetfaucet
WHERE=/tmp/faucet
/busybox/find $WHERE/.limit -mindepth 1 -type d -delete

ut.sh signet
all-sums.sh signet
gen-sfb.sh

cd /home/nsm/.bitcoin/signet/wallets/newnew
list.sh | grep -q " 0 true$" || ash clean-sff.sh
cd /home/nsm/.bitcoin/signet/wallets/pokus202412
ls /tmp/sff | grep -q . || sff-add.sh 1
#find /tmp/sff-s[23] -type f -mmin -1 | grep -q . || sff-add.sh 1
rm -f /tmp/pokus2list
  list.sh | grep "[1-9] true$" | safecat.sh /tmp/pokus2list
  test -s /tmp/pokus2list || echo empty
  num=$(wc -l < /tmp/pokus2list)
  #awklist-all.sh -f $((777*$num)) < /tmp/pokus2list \
  awklist.sh -f $((777*$num)) -a 50000 < /tmp/pokus2list \
    | mktx.sh | crt.sh | srt.sh | sert.sh
rmdir /tmp/locksff

true
