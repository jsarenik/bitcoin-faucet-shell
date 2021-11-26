#!/bin/sh

./prepare.sh
bitcoin-cli -signet echo "hello world" >/dev/null 2>&1 || {
  echo Running in mock mode
  export PATH=$PWD/mock:$PATH
  export WHERE=$PWD/tmp/faucet
}

echo Serving at http://localhost:8123
httpd -f -p 127.0.0.1:8123 -vv
