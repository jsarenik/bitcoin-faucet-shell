#!/bin/sh

test -d "$1" && { cd "$1"; shift; }
test -d .bitcoin && cd .bitcoin
ls | grep -q . || exit 1

# Handling of inside-the-wallet-dir cases
test -r wallet.dat && {
  mypwd=$PWD
  test -L $PWD && mypwd=$(readlink $PWD)
  w="-rpcwallet=${mypwd##*/}"
  test "${mypwd%${mypwd#/}}" = "/" || cd ..
}
cd "${PWD%/wallets*}"
ADD=$(echo ${PWD} | md5sum | cut -b-7)
test "$1" = "-i" && {
  echo $ADD
  exit 0
}

#test -L $PWD && {
#  mypwd=$(readlink $PWD)
#  #echo $mypwd | grep -q "^/" || cd ..
#  test "${mypwd%${mypwd#/}}" = "/" || cd ..
#  cd $mypwd
#}

cmd=bitcoin-cli

test -r blocks || cd ~/.bitcoin

# main signet testnet3 testnet4 regtest liquidv1 liquidtestnet liquidregtest
c="${PWD##*/}"; chain=${c%net3}
echo $chain | grep -qE '^(signet|test|testnet4|regtest|liquid)' \
	&& ddir=${PWD%/*} || chain=""
chain=${chain:-main}
test -d /tmp/bdsd-$chain-$ADD && exit 1

test "${chain%${chain#liquid}}" = "liquid" && cmd=elements-cli

add=""
test "$1" = "-k" && { exec pkill -f "$cmd -datadir=\"${ddir:-$PWD}\""; }
test "$1" = "-g" && exec pgrep -f "$cmd -datadir=\"${ddir:-$PWD}\""
test "$1" = "-t" && { add="-rpcclienttimeout=0"; shift; }

test "$1" = "stop" && mkdir /tmp/bdsd-$chain-$ADD

exec $cmd $add -datadir="${ddir:-$PWD}" -chain=$chain $w "$@"
