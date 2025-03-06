#!/bin/sh
net=$(hnet.sh)
tmp=$(mktemp /dev/shm/catapult-$net-$$-XXXXXX)

myexit() {
  ret=$?
  rm -rf $tmp > /dev/null
  exit $ret
}

cd ~/.bitcoin/signet/wallets/lnanchor

#read -r last < /tmp/signetlast
#genin.sh $last 1 | safecat.sh $tmp

#throw spam
list.sh | grep -v "240 0 false$" | safecat.sh $tmp
test $(wc -l < $tmp) -ge 2 || myexit
test -s $tmp || myexit

#list.sh | sort -n -k3 | safecat.sh $tmp
#list.sh | awk '($3<0.0001){print}' | sort -n -k3 | safecat.sh $tmp
#list.sh | grep " false$" | awk '($3<0.01){print}' | safecat.sh $tmp
grep -q . $tmp && {
awklist-allfeemin.sh < $tmp | crt.sh | sert.sh
myexit

while read line
do
echo $line >&2
echo $line | awklist-allfee.sh | mktx.sh | crt.sh | v3.sh \
  | sert.sh >/dev/null 2>&1
echo $line | awklist-allfee.sh | mktx.sh | crt.sh \
  | sert.sh >/dev/null 2>&1
done < $tmp
}
