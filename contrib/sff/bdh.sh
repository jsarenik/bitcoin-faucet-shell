#!/bin/sh

test -d "$1" && { cd "$1"; shift; }
test -d .bitcoin && cd .bitcoin
ADD=${#PWD}${PWD##*/}
export MALLOC_ARENA_MAX=1

mypwd="$PWD"
test -L "$mypwd" && mypwd="$(readlink $mypwd)"
echo $mypwd | grep -q "^/" || mypwd="../$mypwd"
cd "$mypwd"

# main signet testnet3 testnet4 regtest
c=${PWD##*/}
chain=${c%net3}
case "$chain" in
    signet|test|testnet4|regtest) ddir=${PWD%/*} ;;
    *) chain="" ;;
esac
chain=${chain:-main}

rmdir /tmp/bdsd-$chain-$ADD
exec bitcoind "-datadir=${ddir:-$PWD}" -chain=$chain "$@"
