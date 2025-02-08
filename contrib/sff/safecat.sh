#!/bin/sh

tmp=$(mktemp)
cat > $tmp
chmod a+r $tmp
test -s $tmp && cp -u $tmp $1
rm -f $tmp
