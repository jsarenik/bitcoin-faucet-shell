#!/bin/sh

res() {
  cat <<-EOF
	HTTP/1.1 $1 $2
	Content-Type: $3; charset=utf-8

	$4
	EOF
  exit
}

test "$address" = "" && {
  res 400 "Empty address" application/json '{"message":"Empty address"}'
}

# Early invalid address detection just using grep
# does not leave any trace of the invalid address
echo "$address" | grep -qE '^(tb1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{39}|tb1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{59}|[mn2][a-km-zA-HJ-NP-Z0-9]{25,34})$' || {
  res 400 "Invalid address" application/json '{"message":"Invalid address"}'
}

amount=${amount:-0.0001}
amount=${amount##0.}
amount=0.${amount##.}
# Early invalid amount detection
echo "$amount" | grep -qE '^0{0,1}\.[01][0-9]{0,7}$' || {
  res 400 "Invalid amount" application/json '{"message":"Invalid amount"}'
}

# Set the directory where the rate-limiting data is stored.
# It can be overriden by a global inherited environment variable.
WHERE=${WHERE:-/tmp/faucet}

# Directory containing directories with used addresses
# Should be regularly cleaned
USADDR=${USADDR:-"$WHERE/usaddr"}
op=${address%${address#?}}
ADLOCK=$USADDR/$op/${address##${op}}
mkdir $ADLOCK || { touch $ADLOCK; AA=1; }

# HTTP_X_REAL_IP is the HTTP header set in Caddyfile, falling back
# to the contents of REMOTE_ADDR variable set by busybox httpd
# if not set by the proxying web server.
HTTP_X_REAL_IP=${HTTP_X_REAL_IP:-"$REMOTE_ADDR"}

# Set the file name used for rate-limiting.
LIMIT=$WHERE/.limit/$(echo $HTTP_X_REAL_IP | cut -d: -f1-3 | tr -d '.:\[\]')

mkdir $LIMIT || {
  touch $LIMIT
  res 429 "Slow down" application/json '{"message":"Please slow down"}'
}

test "$AA" = "1" && {
  res 429 "Another address" application/json \
    '{"message":"Use another address"}'
}

bitcoin-cli -signet validateaddress $address | grep -q Invalid && {
  res 400 "Invalid address" application/json '{"message":"Invalid address"}'
}

amsat=$(echo $amount*100000000 | bc | cut -d. -f1)
test $amsat -le 10000000 -a $amsat -ge 10000 || {
  res 400 "Out of bounds" application/json \
    '{"message":"Amount out of boundaries"}'
} && {
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
  } # restofline
} # amount check
