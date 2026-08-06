#!/bin/sh

# optional subtract
fees=${1:-0}
vsize=${2:-0}

net=$(hnet.sh)
gmif=/tmp/gmif-$net
gmifl=${gmif}-lock
mkdir $gmifl || exit 1
gmi.sh | tr -d ', ".' | tr : = \
  | sed 's/=0\+/=/;1,2d;$d' \
  | safecat.sh $gmif
. $gmif
{
test $usage -gt 3996000 \
  || test "$net" = "signet" -a $bytes -gt $((1000000/5)) && {
tf=$(($total_fee-$fees))
b=$(($bytes-$vsize))
test "$tf" = "0" && tf=1
test "$b" = "0" && b=1
mmf=$((1000*${tf:-1}/${b:-1}))
echo $mmf
} || echo 100; } | nicecat.sh /tmp/gmm-$net
rmdir $gmifl
