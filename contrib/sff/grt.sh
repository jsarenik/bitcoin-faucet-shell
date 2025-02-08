#!/bin/sh

bch.sh echo here 2>/dev/null | grep -q . || cd

{ test "$1" = "" && cat || echo "$@"; } \
| while read tx blh rest
do
#curl -sSL "https://mempool.space/api/tx/$tx/hex"
bch.sh getrawtransaction "$tx" 0 $blh
done
