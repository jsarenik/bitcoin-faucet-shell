#!/bin/sh

URL=https://alt.signetfaucet.com/claim
ADDR=tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn

torsocks -i wget -O /dev/null \
  "$URL/?address=$ADDR&amount=0.001"
