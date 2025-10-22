#!/bin/sh

cd ~/.bitcoin/signet

log=/tmp/sfflastnew.log
tail=/tmp/sfflastnew-tail.log
{
date -u
cat /tmp/sfflast
printf "%d payouts" $(wc -l < /tmp/sff-outs)
echo
du -hs /dev/shm/wallets-signet/*
head -1 /dev/shm/half/bitcoind
} | safecat.sh $log
(
  echo
  echo All current LN Anchor outputs seen by this node:
  echo "# txid vout amt conf safe"
  cd ~/.bitcoin/signet/wallets/lnanchor/
  list.sh
) | safeadd.sh $log
tail -n 25 $log | nicecat.sh $tail
