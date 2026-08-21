#!/bin/sh

# optional subtract
feesm=${1:-0}
vsizem=${2:-0}

net=$(hnet.sh)
test "$net" = "test" && net=testnet
test "$net" = "main" || add=/$net
gmif=/tmp/gmif-$net
gmifl=${gmif}-lock
mkdir $gmifl || exit 1
tmp=$(mktemp)

if
  timeout 1 curl -sSL "https://mempool.space${add}/api/mempool" > $tmp
then
  rmdir $gmifl 2>/dev/null
  grep -qi error $tmp && exec gen-gmm.sh $feesm $vsizem
else
  rmdir $gmifl 2>/dev/null
  exec gen-gmm.sh $feesm $vsizem
fi

cat $tmp | tr ',:' '\n=' | head -3 > $tmp-a
mv $tmp-a $tmp

cat $tmp \
  | tr -d '{"' | safecat.sh $tmp
#gmi.sh | tr -d ', ".' | tr : = \
#  | sed 's/=0\+/=/;1,2d;$d' \
#  | safecat.sh $gmif
. $tmp
#cat $tmp >&2

{
# vsize same as usage
bytes=$vsize
test $bytes -gt 3996000 \
  || test "$net" = "signet" -a $bytes -gt $((1000000/5)) && {
tf=$(($total_fee-$feesm))
b=$(($bytes-$vsizem))
test "$tf" = "0" && tf=1
test "$b" = "0" && b=1
mmf=$((1000*${tf:-1}/${b:-1}))
echo $mmf
} || echo 100; } | nicecat.sh /tmp/gmm-$net
##test $vsize -gt 3996000 && {
##echo "$((1000*${total_fee:-1}/${vsize:-1}))"
# | safecat.sh $tmp-a
#grep . $tmp-a
rm -rf ${tmp}*
rmdir $gmifl 2>/dev/null
