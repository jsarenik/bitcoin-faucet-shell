#!/bin/sh

URL=https://pnpfaucet.bublina.eu.org/claim
ADDR=${1:-"tb1q5ygrrwydtuyqxtl8nxkw3wz64d85g3qkq7s0r0"}

/usr/bin/wget \
  "$URL/?address=$ADDR"
