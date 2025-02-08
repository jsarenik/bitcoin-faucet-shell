#!/bin/sh

tmp=$(mktemp)
cat | tee $tmp
chmod a+r $tmp
test -s $tmp && cp -u $tmp $1
rm -f $tmp
