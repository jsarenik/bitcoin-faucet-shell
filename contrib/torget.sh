#!/bin/sh

URL=http://pnpfaucet.bublina.eu.org/claim
ADDR=tb1q5ygrrwydtuyqxtl8nxkw3wz64d85g3qkq7s0r0

torsocks -i /usr/bin/wget -O /dev/null \
  "$URL/?address=$ADDR&amount=0.001"
