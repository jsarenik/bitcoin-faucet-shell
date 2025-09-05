#!/bin/sh

hash=$(sha256sum simplereplnn.sh | cut -b 57-64)
read=$(echo $hash | xxd -r -p | strings -n 1 | tr -d '\n' | grep .)

echo "$hash seen as \"$read\""
