#!/bin/sh
#
# Adds my address to sff

#ls /tmp/sff | grep -q . && exit
test "$1" = "-f" \
  || { find /tmp/sff-s[23] -type f -mmin -1 | grep -q . && exit 1; } \
  && shift
cd /home/nsm/.bitcoin/signet/wallets
cat \
  addresses-bech32-spk \
  addresses-bech32m-spk \
  addresses-legacy-spk \
  | shuf | head -${1:-1} | while read addr size spk rest;
do
  echo "$size $spk" > /tmp/sff/$addr
echo $addr
done
