#!/bin/sh
#
# Usage: mktx.sh < tx.in
# the input contains both types of lines:
#  txid:vout
#  addr,amount

tmp=$(mktemp)
cat > $tmp
echo -n 02000000
num=$(wc -l < $tmp)
if test "$num" -gt 253
then
  echo fd; printf "%0.4x" $num | ce.sh
else
  printf "%0.2x" $num
fi

while read txid vout amt
do
  txidm=$(echo $txid | ce.sh)
  voutm=$(hex ${vout:-0} 8 | ce.sh)
  echo -n "${txidm}${voutm}00feffffff"
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
