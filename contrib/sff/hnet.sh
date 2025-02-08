#!/bin/sh

test -d "$1" && { cd "$1"; shift; }
test -d .bitcoin && cd .bitcoin
#ls | grep -q . || exit 1

while echo "${PWD}" | grep -qw "wallets"; do cd ..; done

test -L $PWD && {
  mypwd=$(readlink $PWD)
  #echo $mypwd | grep -q "^/" || cd ..
  test "${mypwd%${mypwd#/}}" = "/" || cd ..
  cd $mypwd
}

c="${PWD##*/}"; chain=${c%net3}
echo $chain | grep -qE '^(signet|test|testnet4|regtest)$' || chain=""
echo ${chain:-main}
