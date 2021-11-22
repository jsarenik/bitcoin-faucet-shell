#!/bin/sh

#echo "HTTP/1.1 403 Forbidden"
echo "HTTP/1.1 200 OK"
#echo "Content-Type: application/json; charset=UTF-8"
#echo "Content-Type: application/json; charset=UTF-8"
echo "Content-Type: text/html; charset=utf-8"
echo

#{"readyState":4,"responseText":"Please slow down","responseJSON":"{\"message\":\"Please slow down\"}","status":400,"statusText":"error"}
cat <<EOF
Payment of 0.00100000 BTC sent with txid 2f8e854e4c2205aa1ff47e2a73df5996e38102b3bde0fd0d872552ddc5ab2a46
EOF

#exit 1
