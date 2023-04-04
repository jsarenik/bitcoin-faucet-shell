#!/bin/sh

URL=http://signet.bublina.eu.org/claim
ADDR=tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn

torsocks -i /usr/bin/wget -O /dev/null \
  "$URL/?address=$ADDR&amount=0.001"
