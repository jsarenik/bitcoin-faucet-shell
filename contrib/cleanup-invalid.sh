#!/bin/sh

WHERE=${WHERE:-/tmp/faucet}
USADDR=${USADDR:-"$WHERE/usaddr"}
cd $USADDR

find . -mindepth 2 -type d \
  | cut -b3- \
  | while read addr
    do
      a=$(echo $addr | tr -d /)
      bitcoin-cli -signet validateaddress $a \
      | grep -q Invalid \
      && rmdir -v $addr
  done
