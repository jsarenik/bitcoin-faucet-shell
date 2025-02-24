#!/bin/sh

bch.sh echo here 2>/dev/null | grep -q . || cd


{
printf "["
{ test "$1" = "" && cat || echo "$@"; } \
| while read txhex rest
do
echo "\"$txhex\""
done | paste -s -d, | tr -d '\n'; echo ']'
printf "0" # maxfeerate
} | bch.sh -stdin testmempoolaccept
