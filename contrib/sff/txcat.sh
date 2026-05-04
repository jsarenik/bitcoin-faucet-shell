#!/bin/sh
#grep -v '^#' $1 | tr -d ' [A-Z]:\n' | grep .
sed -E 's/#[^ ]+//g' $1 | tr -cd '[0-9a-f]' | grep .
