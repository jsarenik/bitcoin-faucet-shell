#!/bin/ash

HOME=/home/nsm
cd $HOME/.bitcoin/signet/wallets
for rep in $(seq 180)
do
  ash repltotal.sh
  date -u
  sfflog.sh
  sleep 29
done
refreshsignetwallets.sh
exec ash $0
