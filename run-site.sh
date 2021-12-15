#!/bin/sh

./prepare.sh
bitcoin-cli -signet echo "hello world" >/dev/null 2>&1 || {
  echo Running in mock mode
  export PATH=$PWD/mock:$PATH
  WHERE=$PWD/tmp/faucet
}

# Make a fake balance.txt
echo 15.00000000 > balance.txt

export WHERE=${WHERE:-/tmp/faucet}
export USADDR=$WHERE/usaddr

mkdir -p $WHERE/.limit
mkdir $USADDR

# Following are all address prefixes
cd $USADDR
mkdir m n 2 tb1q tb1p
cd -

echo Faucet data is in $WHERE

echo Serving at http://localhost:8123
busybox httpd \
  -c httpd.conf \
  -f -p 127.0.0.1:8123
