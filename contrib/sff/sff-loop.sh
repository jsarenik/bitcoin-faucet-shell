#!/bin/ash

HOME=/home/nsm
cd $HOME/.bitcoin/signet/wallets
ls /tmp/sff | grep -q . \
  && {
  ash repltotal.sh
  date -u
  }
sleep 15
exec ash $0
