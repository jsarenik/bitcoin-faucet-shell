#!/bin/ash

HOME=/home/nsm
cd $HOME/.bitcoin/signet/wallets
for rep in $(seq 080)
do
  ash repltotal.sh
  date -u
  sfflog.sh
  sleep 29; rmdir /tmp/locksff /tmp/sfflock
done
ash ~/bin/refreshsignetwallets.sh
exec ash $0
