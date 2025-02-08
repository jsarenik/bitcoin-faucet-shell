#!/bin/sh

test -d "$1" && { cd "$1"; shift; }
test -d .bitcoin && cd .bitcoin
ls | grep -q . || exit 1

# Handling of inside-the-wallet-dir cases
test -r wallet.dat && {
  mypwd=$PWD
  test -L $PWD && mypwd=$(readlink $PWD)
  w="-rpcwallet=${mypwd##*/}"
}
cd ${PWD%%/wallets*}

test -L $PWD && {
  mypwd=$(readlink $PWD)
  #echo $mypwd | grep -q "^/" || cd ..
  test "${mypwd%${mypwd#/}}" = "/" || cd ..
  cd $mypwd
}

cmd=bitcoin-cli

test -r blocks || cd ~/.bitcoin

# main signet testnet3 testnet4 regtest liquidv1 liquidtestnet liquidregtest
c="${PWD##*/}"; chain=${c%net3}
echo $chain | grep -qE '^(signet|test|testnet4|regtest|liquid)' \
	&& ddir=${PWD%/*} || chain=""

test "${chain%${chain#liquid}}" = "liquid" && cmd=elements-cli

test "$1" = "-k" && exec pkill -f "$cmd -datadir=${ddir:-$PWD}"
test "$1" = "-g" && exec pgrep -f "$cmd -datadir=${ddir:-$PWD}"

exec $cmd -rpcclienttimeout=0 -datadir=${ddir:-$PWD} -chain=${chain:-main} $w "$@"
