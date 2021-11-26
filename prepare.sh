#!/bin/sh

BV=0.9.3
BULMA=https://github.com/jgthms/bulma/releases/download/$BV/bulma-$BV.zip
mkdir tmp 2>/dev/null
test -r tmp/bulma.zip || {
  wget -q -O tmp/bulma.zip $BULMA
}
USESTYLE=bulma/css/bulma.css
test -r tmp/$USESTYLE || {
  (cd tmp; unzip bulma.zip $USESTYLE)
}

mkdir css 2>/dev/null
./transform-bulma.sh > css/main.css
