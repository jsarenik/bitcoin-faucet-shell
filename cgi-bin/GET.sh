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

WHERE=/tmp/faucet
mkdir $WHERE/.limit/$address || {
  res 429 "Another address" application/json \
    '{"message":"Please use another address"}'
} && {
NOW=$(date +%s)
HTTP_X_REAL_IP=${HTTP_X_REAL_IP:-"$REMOTE_ADDR"}
# Limit number of seconds from last POST attempt
LIMITS=3600
LIMIT=$WHERE/.limit/$(echo $HTTP_X_REAL_IP | tr -d '.:[]')
LAST=$(stat -c "%Y" $LIMIT 2>/dev/null || echo 999; touch $LIMIT) && {
  test $((NOW-LAST)) -le $LIMITS && {
    res 429 "Slow down" application/json '{"message":"Please slow down"}'
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
  fee_rate=1 | grep .)" \
|| {
  res 400 "Something wrong" text/html "Something went wrong"
} && {
  res 200 OK text/html "Payment of ${amount:-0} BTC sent with $restofline"
#Payment of ${amount:-0} BTC sent with txid 2f8e854e4c2205aa1ff47e2a73df5996e38102b3bde0fd0d872552ddc5ab2a46
}
