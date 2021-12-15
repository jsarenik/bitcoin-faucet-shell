#!/bin/sh

OURDIR=$PWD
WHERE=${WHERE:-/tmp/faucet}
USADDR=${USADDR:-"$WHERE/usaddr"}

cd $WHERE
find . -type d \
  | cut -b3- \
  | while read addr
    do
  ND=$(sh $OURDIR/blocktime.sh $addr) \
    && mkdir -p $USADDR/$ND
  done
