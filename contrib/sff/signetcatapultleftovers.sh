#!/bin/sh
sdi=$HOME/.bitcoin/signet
myp=$sdi/wallets
wd=$myp/newnew
cd $wd

net=$(hnet.sh)
tmp=$(mktemp /dev/shm/catapultleft-$net-XXXXXX)
prev=/dev/shm/previosleftovers-$net
list=$tmp
lh=${list}-hex

: > $list
list.sh | grep " false$" | safecat.sh $list
cat $list | awk '{print $1}' | safecat.sh ${list}-grep
test -s $list && {
num=$(wc -l < $list)
cd $wd
cat $list | awklist.sh \
  | mktx.sh | crt.sh | srt.sh | safecat.sh $lh
fee=$(fee.sh < $lh)
echo fee $fee >&2
cd $wd
cat $list | awklist.sh -f $fee -a 99999 \
  | mktx.sh | crt.sh | srt.sh | safecat.sh $lh
sert.sh <$lh
}
cp $list $prev
rm -rf ${tmp}* > /dev/null
