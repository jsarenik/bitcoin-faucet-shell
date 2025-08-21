#!/bin/sh

net=$(hnet.sh)
gmif=/tmp/gmif-$net
gmi.sh | tr -d ', ".' | tr : = \
  | sed 's/=0\+/=/;1,2d;$d' \
  | safecat.sh $gmif
. $gmif
test $usage -gt 3996000 && {
tf=$total_fee
b=$bytes
test "$tf" = "0" && tf=1
test "$b" = "0" && b=1
mmf=$((1000*${tf:-1}/${b:-1}))
echo $mmf
} | nicecat.sh /tmp/gmm-$net \
  || echo 1500
