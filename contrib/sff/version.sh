#!/bin/sh

hash=$(sha256sum simplereplnn.sh | cut -b 59-64)
hash="76$hash"
read=$(echo $hash | xxd -r -p | strings -n 1 | tr -d '\n' | grep .)

echo "$hash seen as \"$read\""
