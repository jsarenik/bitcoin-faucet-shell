#!/bin/sh

rm balance.txt 2>/dev/null
git rev-parse --short HEAD > version.txt
#./prepare-css.sh
test -r css/main.css || {
  cd css
  wget https://signetfaucet.com/css/main.css
  cd ..
}
brotli-it.sh
rsync -av --exclude=balance.txt --exclude=tmp \
  --delete . singer:web/pnp-faucet/
