#!/bin/ash

HOME=/home/nsm
cd $HOME/.bitcoin/signet/wallets
for rep in $(seq 080)
do
  ash repltotal.sh; timeout 2 gen-sfb.sh
  date -u
  sfflog.sh
  sleep 29
  rmdir /tmp/locksff /tmp/sfflock /tmp/gen-sfb-lock /tmp/rebroadcast-all.sh-1efbc0f1
done
ash ~/bin/refreshsignetwallets.sh
exec ash $0
