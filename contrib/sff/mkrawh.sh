#!/bin/sh
#
# Usage: mkrawh.sh < tx.in
# the input contains one line and raw hex tx on it
# (like from getrawtransaction)

tmp=$(mktemp)
cat > $tmp
echo -n 02000000
printf "%0.2x" $(wc -l < $tmp)
while read txid vout amt
do
  txidm=$(echo $txid | ce.sh)
  voutm=$(hex ${vout:-0} 8 | ce.sh)
  echo -n "${txidm}${voutm}00feffffff"
done < $tmp
rm -rf ${tmp}*
echo
