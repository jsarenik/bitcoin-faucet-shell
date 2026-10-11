#!/bin/sh
cd ~/.bitcoin/signet/wallets
(
  for i in newmy*
  do
    cd $i
    list.sh 2>/dev/null | grep -q . || echo $i
    cd ~/.bitcoin/signet/wallets
  done
) | safecat.sh /tmp/cw

(cd /dev/shm/wallets-signet/; xargs rm -rfv;) < /tmp/cw
(cd /home/nsm/.bitcoin/signet/wallets; xargs rm -rfv;) < /tmp/cw
