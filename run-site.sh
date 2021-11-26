#!/bin/sh

./prepare.sh

echo Serving at http://localhost:8123
httpd -f -p 127.0.0.1:8123 -vv
