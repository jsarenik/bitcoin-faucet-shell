#!/bin/sh

URL=https://signet.bublina.eu.org/claim
ADDR=${1:-"tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn"}

/usr/bin/wget \
  "$URL/?address=$ADDR"
