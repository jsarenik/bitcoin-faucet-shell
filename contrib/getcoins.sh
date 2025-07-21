#!/bin/sh

host=signet257.bublina.eu.org
URL=https://$host/claim
ADDR=${1:-"tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn"}
ADDR=${1:-"04a8c3fa3dbc022ca7c9a2214c5e673833317b3cff37c0fc170fc347f1a2f6b6e2a53db4d023387f89209de481cd014a44040e1b09c3226d40fed02c0bc8d0f548"}
ADDR=${1:-"tb1pfees9rn5nz"}

/usr/bin/wget -qO - \
  "${URL}/?address=$ADDR&cfts=fake" \
  --header 'referer: https://signet257.bublina.eu.org/'
