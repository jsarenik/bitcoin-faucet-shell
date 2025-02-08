#!/bin/sh

txid=$1
wall=$2
hash=$3
height=$4

echo "$wall" | grep -q "newmy" && signetcatapult.sh
test "$wall" = "lnanchor" && signetcatapultlna.sh

true
