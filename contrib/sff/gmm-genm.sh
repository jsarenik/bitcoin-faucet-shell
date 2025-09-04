#!/bin/sh

net=$(hnet.sh)
test "$net" = "test" && net=testnet
test "$net" = "main" || add=/$net
gmif=/tmp/gmif-$net
tmp=$(mktemp)

until
  curl -sSL "https://mempool.space${add}/api/mempool" > $tmp
  grep -qvi error $tmp
do
  sleep 1
done

cat $tmp | tr ',:' '\n=' | head -3 > $tmp-a
mv $tmp-a $tmp

cat $tmp \
  | tr -d '{"' | safecat.sh $tmp
. $tmp
#cat $tmp

#exit

{
test $vsize -gt 3996000 && {
echo "$((1000*${total_fee:-1}/${vsize:-1}))"
# | safecat.sh $tmp-a
#grep . $tmp-a
} || echo 1000; } | nicecat.sh /tmp/gmm-$net
rm -rf ${tmp}*
