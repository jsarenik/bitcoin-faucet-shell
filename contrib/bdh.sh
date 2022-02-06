#!/bin/sh

test "${PWD##*/}" = "testnet3" && { D="$PWD/.."; O="-testnet"; }
test "${PWD##*/}" = "signet" && { D="$PWD/.."; O="-signet"; }

exec bitcoind "-datadir=${D:-$PWD}" $O "$@"
