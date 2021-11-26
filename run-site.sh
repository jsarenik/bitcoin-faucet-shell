#!/bin/sh

./prepare.sh
bitcoin-cli -signet echo "hello world" >/dev/null 2>&1 || {
  echo Running in mock mode
  export PATH=$PWD/mock:$PATH
  WHERE=$PWD/tmp/faucet
}

export WHERE=${WHERE:-/tmp/faucet}
mkdir -p $WHERE/.limit
echo Faucet data in $WHERE

echo Serving at http://localhost:8123
busybox httpd \
  -c httpd.conf \
  -f -p 127.0.0.1:8123 -vv
