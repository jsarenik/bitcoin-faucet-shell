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
list.sh | grep " 0 false$" | safecat.sh $list
cat $list | awk '{print $1}' | safecat.sh ${list}-grep
test -s $list && {
num=$(wc -l < $list)
cd $wd
cat $list | awk '($3>0.01){print $1, $2, $3}' | while read txid vout amount rest; do
 echo $txid $vout $amount >&2
 echo $txid $vout $amount | awklist.sh -d tb1pfees9rn5nz \
  | mktx.sh | crt.sh | srt.sh | safecat.sh $lh
fee=$(fee.sh < $lh)
fee=${fee:-190}
echo fee $fee >&2
cd $wd
#cat $list | awklist.sh -f ${fee:-190} -d tb1pfees9rn5nz -a 99999 \
 echo $txid $vout $amount | awklist.sh -f $fee -d tb1pfees9rn5nz -a 123456 \
  | mktx.sh | crt.sh | srt.sh | safecat.sh $lh
sert.sh <$lh
done

cat $list | awk '($3<=0.01){print $1, $2, $3}' | while read txid vout amount rest; do
 echo $txid $vout $amount >&2
 echo $txid $vout $amount | awklist-allfee.sh \
  | mktx.sh | crt.sh | srt.sh | sert.sh
done
}
cp $list $prev
rm -rf ${tmp}* > /dev/null
