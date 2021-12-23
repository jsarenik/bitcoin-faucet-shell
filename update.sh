#!/bin/sh

rm balance.txt 2>/dev/null
git rev-parse --short HEAD > version.txt
./prepare-css.sh
rsync -av --exclude=balance.txt --exclude=tmp \
  --delete . singer:web/bitcoin-faucet-shell/
