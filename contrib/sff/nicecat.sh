#!/bin/sh

tmp=$(mktemp /tmp/tmp-nicecat.XXXXXX)
cat | tee $tmp
chmod a+r $tmp
test -s $tmp && cp -u $tmp $1
#cp -u $tmp $1
rm -f $tmp
