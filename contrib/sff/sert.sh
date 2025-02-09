#!/bin/sh

while read line; do
{
echo $line
echo 0
} | bch.sh -stdin sendrawtransaction
done
