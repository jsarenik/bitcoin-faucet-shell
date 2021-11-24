#!/bin/sh

#echo "HTTP/1.1 403 Forbidden"
#echo "Content-Type: application/json; charset=UTF-8"
#echo "Content-Type: application/json; charset=UTF-8"

#ADCHARS=$(echo $address | wc -c)
#ADCHARS=${ADCHARS:-"0"}
#test $ADCHARS -lt 10 -o $ADCHARS -gt 100 && {
bitcoin-cli -signet validateaddress $address | grep -q Invalid && {
cat <<EOF
HTTP/1.1 400 Invalid address
Content-Type: application/json; charset=utf-8

{"message":"Invalid address"}
EOF
exit
}

WHERE=/tmp/faucet
mkdir $WHERE/.limit/$address || {
cat <<EOF
HTTP/1.1 429 Another address
Content-Type: application/json; charset=utf-8

{"message":"Please use another address"}
EOF
exit 1
} && {
NOW=$(date +%s)
HTTP_X_REAL_IP=${HTTP_X_REAL_IP:-"$REMOTE_ADDR"}
# Limit number of seconds from last POST attempt
LIMITS=3600
LIMIT=$WHERE/.limit/$(echo $HTTP_X_REAL_IP | tr -d '.:[]')
LAST=$(stat -c "%Y" $LIMIT 2>/dev/null || echo 999; touch $LIMIT) && {
  test $((NOW-LAST)) -le $LIMITS && {
#    echo "{\"status\":1,\"message\":\"Please wait $LIMITS seconds between \
#each post. Counter is reset on every retry.\"}"
cat <<EOF
HTTP/1.1 429 Slow down
Content-Type: application/json; charset=utf-8

{"message":"Please slow down"}
EOF
    exit 1
  }
}
}

amount=0.0001
#restofline=$(lightning-cli --signet withdraw $address ${amount:-0}btc slow \
#  | grep txid | tr -d '":,' | cut -b4- | grep .) || {
restofline="txid $(bitcoin-cli -signet -named sendtoaddress \
  address=$address \
  amount=$amount \
  subtractfeefromamount=true \
  replaceable=true \
  avoid_reuse=false \
  fee_rate=1 | grep .)"  || {
cat <<EOF
HTTP/1.1 400 Something wrong
Content-Type: text/html; charset=utf-8

Something went wrong
EOF
exit 1
} && {
cat <<EOF
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8

Payment of ${amount:-0} BTC sent with $restofline
EOF
#Payment of ${amount:-0} BTC sent with txid 2f8e854e4c2205aa1ff47e2a73df5996e38102b3bde0fd0d872552ddc5ab2a46
}
