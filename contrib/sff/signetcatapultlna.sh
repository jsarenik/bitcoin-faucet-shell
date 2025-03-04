#!/bin/sh
net=$(hnet.sh)
tmp=$(mktemp /dev/shm/catapult-$net-$$-XXXXXX)

cd ~/.bitcoin/signet/wallets/lnanchor

#read -r last < /tmp/signetlast
#genin.sh $last 1 | safecat.sh $tmp

#throw spam
list.sh | sort -n -k3 | safecat.sh $tmp
#list.sh | awk '($3<0.0001){print}' | sort -n -k3 | safecat.sh $tmp
#list.sh | grep " false$" | awk '($3<0.01){print}' | safecat.sh $tmp
grep -q . $tmp && {
while read line
do
echo $line >&2
echo $line | awklist-allfee.sh | mktx.sh | crt.sh | v3.sh \
  | sert.sh >/dev/null 2>&1
echo $line | awklist-allfee.sh | mktx.sh | crt.sh \
  | sert.sh >/dev/null 2>&1
done < $tmp
}

rm -rf $tmp > /dev/null
