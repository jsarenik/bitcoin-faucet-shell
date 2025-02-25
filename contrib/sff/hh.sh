#!/bin/sh

a="/$0"; a=${a%/*}; a=${a:-.}; a=${a#/}/; B=$(cd "$a" || true; pwd)
test -d "$1" && { cd "$1"; shift; }

while echo "${PWD}" | grep -qw "wallets"; do cd ..; done

test "${PWD##*/}" = "signet" && chain=--signet
test "${PWD##*/}" = "testnet3" && chain=--testnet
test "${PWD##*/}" = "testnet4" && chain=--testnet
test "${PWD##*/}" = "regtest" && chain=--regtest

export LD_LIBRARY_PATH=$B/lib

exec hal ${chain} "$@"
