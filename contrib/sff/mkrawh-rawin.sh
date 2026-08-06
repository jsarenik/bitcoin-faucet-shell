#!/bin/sh
#
# Usage: mktx.sh < tx.in
# the input contains both types of lines:
#  txid:vout
#  addr,amount

tmp=$(mktemp)
trap "rm -rf ${tmp}*" EXIT INT QUIT
cat > $tmp
echo -n 02000000
numlines=$(wc -l < $tmp)
echo $numlines | grep -q '[0-9]\+' || numlines=1
printf "%0.2x" ${numlines:-1}
while read txid vout rest
do
  #txidm=$(echo $txid | ce.sh)
  #voutm=$(hex ${vout:-0} - 8 | ce.sh)
  #echo -n "${txidm}${voutm}00feffffff"
  echo -n "${txid}${vout}00feffffff"
done < $tmp
rm -rf ${tmp}*
echo
exit

oldifs=$IFS

{
echo '['
IFS=:
grep -v "^#" $tmp | grep ":" | while read txid vout
do
cat <<EOF
{"txid":"$txid","vout":$vout}
EOF
done | paste -d, -s
echo ']'
} | tr -d '\n '; echo

{
echo '['
IFS=,
grep -v "^#" $tmp | grep "," | while read addr amount
do
cat <<EOF
{"$addr":$amount}
EOF
done | paste -d, -s
echo ']'
} | tr -d '\n '
echo
echo 0
#$(($RANDOM%12345))
echo true
