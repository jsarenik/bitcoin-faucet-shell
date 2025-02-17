#!/bin/sh

URL=https://signet.bublina.eu.org/claim
ADDR=tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn

curl \
  --preproxy 'socks://192.168.3.54:9100' \
  "$URL/?address=$ADDR&amount=0.001"
