#!/bin/sh

export PATH=/busybox:$PATH
export WHERE=/tmp/faucet
export USADDR=$WHERE/usaddr
export USTXID=$WHERE/ustxid

tail -F $HOME/log/bitcoind-signet/current \
  | awk '{print}' \
  | while read line;
  do
    echo $line | grep 'AddToWallet' | grep -oE '[0-9a-f]{64}' | while read tx;
      do
        echo $tx
        #bitcoin-cli -signet getrawtransaction $tx true | jq -r .vin[].txid | while read oldtx;
        #do
        #  rm $USTXID/$tx/* && rmdir $USTXID/$tx
        #done
      done
    echo $line | grep 'update$' && gen-sfb.sh < /dev/null;
    echo $line | grep UpdateTip && bitcoin-cli -signet getblockcount > /dev/shm/signet-block
  done

# does not work  | sed -n '/AddToWallet/p' \
# this works: | /busybox/awk '/AddToWallet/{print $0}' \
