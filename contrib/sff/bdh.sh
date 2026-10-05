#!/bin/sh

test -d "$1" && { cd "$1"; shift; }
test -d .bitcoin && cd .bitcoin
ADD=$(echo ${PWD} | md5sum | cut -b-7)
export MALLOC_ARENA_MAX=1

mypwd="$PWD"
test -L "$mypwd" && mypwd="$(readlink $mypwd)"
echo $mypwd | grep -q "^/" || mypwd="../$mypwd"
cd "$mypwd"

echo "${PWD##*/}" | grep "^signet" && chain=signet
test "${PWD##*/}" = "testnet3" && chain=test
test "${PWD##*/}" = "testnet4" && chain=testnet4
test "${PWD##*/}" = "regtest" && chain=regtest
test "$chain" = "" && chain=main || ddir=${PWD%/*}

rmdir /tmp/bdsd-$chain-$ADD
exec bitcoind "-datadir=${ddir:-$PWD}" -chain=$chain "$@"
