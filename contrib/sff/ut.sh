#!/bin/sh

hash=$1
net=${2:-"main"}
fn=$net
test "$net" = "main" && fn=bitcoin
log=$HOME/log/bitcoind-$net/current

getline() {
  test -n "$hash" \
    && grep "best=$hash" $log \
    || { grep "UpdateTip" $log | tail -1; }
}

getline | cut -b42- | tr ' ' '\n' \
  | grep -E "^(best|height|version|log2_work|tx|date|progress)=" \
  | safecat.sh /dev/shm/UpdateTip-$fn
