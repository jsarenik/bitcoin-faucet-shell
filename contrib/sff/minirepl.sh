#!/bin/sh

ml=/tmp/mr-list
tx=${1:-$(list.sh | sort -rnk3 | head -1 | safecat.sh $ml; read a b <$ml; echo $a)}

grt.sh $tx | safecat.sh $ml-grt
vsize=$(cat $ml-grt | fee.sh -o)

amt=$(drt.sh < $ml-grt | grep -m1 -w '"value"' | tr -cd '[0-9]' | sed 's/^0\+//')
oamt=$(hex $amt - 16 | ce.sh)

gmm=$(gmm.sh)
amt=$(( $amt-512-(($vsize+9)/10) ))
hamt=$(hex $amt - 16 | ce.sh)

sed -E "s|${oamt}22|${hamt}22|" $ml-grt \
  | txcat.sh | srt.sh | sertl.sh
