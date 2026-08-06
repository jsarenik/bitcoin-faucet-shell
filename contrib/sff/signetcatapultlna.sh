#!/bin/sh

net=$(hnet.sh)
tmp=$(mktemp /dev/shm/catapult-$net-$$-XXXXXX)

myexit() {
  ret=$?
  rm -rf $tmp > /dev/null
  exit $ret
}

trap myexit EXIT INT QUIT
cd ~/.bitcoin/signet/wallets/lnanchor

#read -r last < /tmp/signetlast
#genin.sh $last 1 | safecat.sh $tmp

#throw spam
#list.sh | grep " true$" | safecat.sh $tmp
#list.sh | grep " 0.00000000 " | safeadd.sh $tmp
list.sh | grep -v " 0.00000000 " | grep " true$" | safecat.sh $tmp
#list.sh | safecat.sh $tmp
#grep "123456 " $tmp || myexit
#test $(wc -l < $tmp) -ge 2 || myexit
test -s $tmp || myexit
cat $tmp

#list.sh | sort -n -k3 | safecat.sh $tmp
#list.sh | awk '($3<0.0001){print}' | sort -n -k3 | safecat.sh $tmp
#list.sh | grep " false$" | awk '($3<0.01){print}' | safecat.sh $tmp
grep -q . $tmp && {
awklist-allfee.sh < $tmp | mktx.sh | crt.sh | psert.sh

# throw the rest (unconfirmed v3?)
list.sh | grep " false$" | awklist-allfee.sh | mktx.sh | crt.sh | v3.sh | sert.sh
myexit

while read line
do
echo $line >&2
echo $line | awklist-allfee.sh | mktx.sh | crt.sh | v3.sh \
  | psert.sh >/dev/null 2>&1
echo $line | awklist-allfee.sh | mktx.sh | crt.sh \
  | psert.sh >/dev/null 2>&1
done < $tmp
}
