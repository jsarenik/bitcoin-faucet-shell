#!/bin/sh
#
# Usage: mktx.sh < tx.in
# the input contains both types of lines:
#  txid:vout
#  addr,amount
# 
# Legacy usage: mktx.sh <dir>
# the dir contains two text files:
# in
#  txid:vout
# out
#  addr,amount

net=$(hnet.sh)
height=1
#test "$net" = "signet" || . /dev/shm/UpdateTip-$net
echo $PWD | grep -q chaincode || . /dev/shm/UpdateTip-$net
tmp=$(mktemp)
if
  test -n "$1" && test -d $1
then
  cat $1/in $1/out > $tmp
else
  cat > $tmp
fi
oldifs=$IFS

{
echo '['
IFS=:
first=1
grep -v "^#" $tmp | grep ":" | shuf | while read txid vout rest
do
test "$first" = 1 || echo ,
first=0
cat <<EOF
{"txid":"$txid","vout":$vout}
EOF
done
echo ']'
} | tr -d '\n '; echo

{
echo '['
IFS=,
first=1
#grep -v "^#" $tmp | grep "," | shuf | while read addr amount
grep -v "^#" $tmp | grep "," | while read addr amount rest
do
test "$first" = 1 || echo ,
first=0
cat <<EOF
{"$addr":$amount}
EOF
done
echo ']'
} | tr -d '\n '
echo
echo $height
#$(($RANDOM%12345))
echo true
rm $tmp
