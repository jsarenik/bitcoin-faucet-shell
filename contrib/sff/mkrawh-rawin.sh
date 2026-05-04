#!/bin/sh
#
# This does the same as mkrawh.sh but accepts
# raw inputs like from listraw.sh

tmp=$(mktemp)
trap "rm -rf ${tmp}*" EXIT INT QUIT
cat > $tmp
echo -n 02000000
numlines=$(wc -l < $tmp)
echo $numlines | grep -q '[0-9]\+' || numlines=1
printf "%0.2x" ${numlines:-1}
while read txid vout rest
do
  echo -n "${txid}${vout}00feffffff"
done < $tmp
rm -rf ${tmp}*
echo
