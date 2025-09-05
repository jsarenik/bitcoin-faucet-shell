#!/bin/sh

net=${1:-"main"}
fn=$net
test "$net" = "main" && fn=bitcoin
log=$HOME/log/bitcoind-$net/current
grep UpdateTip: $log \
  | tail -1 | cut -b42- | tr ' ' '\n' | head -7 \
  | safecat.sh /dev/shm/UpdateTip-$fn
#echo >> $log
#echo > $log
#  | sed '/^date=/s/T/ /' \
