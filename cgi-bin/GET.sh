#!/bin/sh

cd $DATADIR

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
echo "$address" | grep -qE '^(tb1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{39}|tb1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{59}|[mn2][a-km-zA-HJ-NP-Z1-9]{25,34})$' || {
  res 400 "Invalid address" application/json '{"message":"Invalid address"}'
}

# Left for backward API compatibility, the amount is ignored further
amount=${amount:-0.0001}
amount=${amount##0.}
amount=0.${amount##.}
# Early invalid amount detection
echo "$amount" | grep -qE '^0{0,1}\.[01][0-9]{0,7}$' || {
  res 400 "Invalid amount" application/json '{"message":"Invalid amount"}'
}

# Make sure the amount makes sense early enough as it is a simple
# computation not requiring any external binary.
amsat=$(echo $amount*100000000 | bc | cut -d. -f1)
test $amsat -le 10000000 -a $amsat -ge 10000 || {
  res 400 "Out of bounds" application/json \
    '{"message":"Amount out of boundaries"}'
}

# Supplied amount is ignored and set to a random value starting with 0.00
# at least 5000 satoshi (500 minimum is 0.0000500 == 0.00005000)
# $RANDOM maximum value seems to be 5 digits long so add one more zero
amount=0.00$(printf "%05d" $((RANDOM + 500)))0

# Checking address with bitcoin-cli in this stage should be pretty
# cheap as all totally invalid addresses are already ruled out
# and we make sure that space is saved by not allowing to create
# unlimited number of directories which would pass the regex rule
# but would be actually invalid addresses.
bch.sh validateaddress $address | grep -q Invalid && {
  res 400 "Invalid address" application/json '{"message":"Invalid address"}'
}

# Set the directory where the rate-limiting data is stored.
# It can be overriden by a global inherited environment variable.
WHERE=${WHERE:-/tmp/faucet}

# Directory containing directories with used addresses
# Should be regularly cleaned
USADDR=${USADDR:-"$WHERE/usaddr"}
op=${address%${address#?}}
test "$op" = "t" && op=${address%${address#????}}
ADLOCK=$USADDR/$op/${address##${op}}
mkdir -p ${ADLOCK%/*}
mkdir $ADLOCK 2>/dev/null || { touch $ADLOCK; AA=1; }

# HTTP_X_REAL_IP is the HTTP header set in Caddyfile, falling back
# to the contents of REMOTE_ADDR variable set by busybox httpd
# if not set by the proxying web server.
HTTP_X_REAL_IP=${HTTP_X_REAL_IP:-"$REMOTE_ADDR"}

# Set the file name used for rate-limiting.
LIMIT=$WHERE/.limit/$(echo $HTTP_X_REAL_IP | cut -d: -f1-3 | tr -d '.:\[\]')

mkdir -p ${LIMIT%/*}
mkdir $LIMIT 2>/dev/null || {
  touch -r $ADLOCK $LIMIT
  res 429 "Slow down" application/json '{"message":"Please slow down"}'
}

touch -r $ADLOCK $LIMIT

test "$AA" = "1" && {
  res 429 "Another address" application/json \
    '{"message":"Use another address"}'
}

cd $HOME/.bitcoin-plebnet/signet/wallets/wosh-default
restofline="txid $(wosh send $address | grep .)" \
|| {
  res 400 "Something wrong" text/html "Something went wrong"
} && {
  res 200 OK text/html "Random small payment sent with $restofline"
} # restofline
