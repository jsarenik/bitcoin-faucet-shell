#!/bin/sh

BV=0.9.3
BULMA=https://github.com/jgthms/bulma/releases/download/$BV/bulma-$BV.zip
mkdir tmp 2>/dev/null
test -r tmp/bulma.zip || {
  wget -O tmp/bulma.zip $BULMA
}
test -r tmp/bulma/css/bulma.css || {
  (cd tmp; unzip bulma.zip)
}

mkdir css 2>/dev/null
./transform-bulma.sh > css/main.css
