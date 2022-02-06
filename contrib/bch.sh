#!/bin/sh

test "${PWD##*/}" = "testnet3" && { D="$PWD/.."; O="-testnet"; }
test "${PWD##*/}" = "signet" && { D="$PWD/.."; O="-signet"; }

exec bitcoin-cli "-datadir=${D:-$PWD}" $O "$@"
