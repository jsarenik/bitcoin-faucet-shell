#!/bin/sh

test "$1" = "" && read -r hex || hex=$(grt.sh $1)
size=$((${#hex}/2))
nonseg=$(echo $hex | nd.sh | txcat.sh)
nsize=$((${#nonseg}/2))
rest=$(($size-$nsize))
vsize=$(($nsize+($rest+3)/4))
echo $vsize
