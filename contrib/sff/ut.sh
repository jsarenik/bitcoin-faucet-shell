#!/bin/sh

net=${1:-"main"}
fn=$net
test "$net" = "main" && fn=bitcoin
log=$HOME/log/bitcoind-$net/current
grep UpdateTip: $log \
  | tail -1 | cut -b42- | tr ' ' '\n' \
  | grep -E "^(best|height|version|log2_work|tx|date|progress)=" \
  | safecat.sh /dev/shm/UpdateTip-$fn
