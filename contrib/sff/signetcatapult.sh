#!/bin/sh
exit 1

#sleep 1
lock=/tmp/locksff
test -d $lock && exit 1

net=$(hnet.sh)
###tmp=$(mktemp /dev/shm/catapult-$net-XXXXXX)

cd ~/.bitcoin/signet/wallets/newnew

#read -r last < /tmp/signetlast
#genin.sh $last 1 | safecat.sh $tmp

#throw spam
list.sh | grep " true$" | awk '($3<=0.001 && $3>=0.00000240){print}' | safecat.sh $tmp
#list.sh | awk '($3<0.01 && $3>=0.00000240){print}' | safecat.sh $tmp
#list.sh | grep " false$" | awk '($3<0.01){print}' | safecat.sh $tmp
grep -q . $tmp && {
while read line
do
fee=$(echo $line | awklist-allfee.sh | mktx.sh | crt.sh | srt.sh | fee.sh)
echo $line | awklist-allfee.sh -f $fee -fm | mktx.sh | crt.sh | srt.sh \
  | sert.sh 2>&1
# | safecat.sh /tmp/lastcatapultx
done < $tmp
}
rm -rf $tmp > /dev/null

#signetcatapultleftovers.sh
