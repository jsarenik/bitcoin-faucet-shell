#!/bin/sh

res() {
  cat <<-EOF
	HTTP/1.1 $1 $2
	Content-Type: $3; charset=utf-8

	$4
	EOF
  exit
}

test "$address" = "" && exit 1

bitcoin-cli -signet validateaddress $address | grep -q Invalid && {
  res 400 "Invalid address" application/json '{"message":"Invalid address"}'
}

WHERE=${WHERE:-/tmp/faucet}
HTTP_X_REAL_IP=${HTTP_X_REAL_IP:-"$REMOTE_ADDR"}
LIMIT=$WHERE/.limit/$(echo $HTTP_X_REAL_IP | tr -d '.:[]')
LAST=$(stat -c "%Y" $LIMIT 2>/dev/null || echo 999; touch $LIMIT)
mkdir $WHERE/.limit/$address || AA=1
NOW=$(date +%s)
# Limit number of seconds from last POST attempt
LIMITS=3600
# If loopback address (Tor), make the limit shorter
echo $HTTP_X_REAL_IP | grep -q "^127.0.0.1$" && LIMITS=30
test $((NOW-LAST)) -le $LIMITS && {
  res 429 "Slow down" application/json '{"message":"Please slow down"}'
}

test "$AA" = "1" && {
  res 429 "Another address" application/json \
    '{"message":"Use another address"}'
}

amount=${amount:-0.0001}
#restofline=$(lightning-cli --signet withdraw $address ${amount:-0}btc slow \
#  | grep txid | tr -d '":,' | cut -b4- | grep .) || {
restofline="txid $(bitcoin-cli -signet -named sendtoaddress \
  address=$address \
  amount=$amount \
  subtractfeefromamount=true \
  replaceable=true \
  avoid_reuse=false \
  fee_rate=1 | grep .)" \
|| {
  res 400 "Something wrong" text/html "Something went wrong"
} && {
  res 200 OK text/html "Payment of ${amount:-0} BTC sent with $restofline"
#Payment of ${amount:-0} BTC sent with txid 2f8e854e4c2205aa1ff47e2a73df5996e38102b3bde0fd0d872552ddc5ab2a46
}
