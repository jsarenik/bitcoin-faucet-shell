#!/bin/sh

#printenv | grep -q "^HTTP_REFERER=https://mintsquare.io" && exit 1
#test "$HTTP_CF_CONNECTING_IP" = "144.48.80.101" && exit 1

res() {
  cat <<-EOF
	HTTP/1.1 $1 $2
	Content-Type: ${3:-application/json}; charset=utf-8

	${4:-$2}
	EOF
  exit
}

#echo "$HTTP_ACCEPT_LANGUAGE" | grep -q "^zh-CN" && res 429 "Hello World"
#echo "$HTTP_SEC_CH_UA_PLATFORM" | grep -qw "Windows" && res 429 "Keep learning"
#test "$HTTP_REFERER" = "https://$HTTP_X_FORWARDED_HOST/" \
#  -a "$HTTP_SEC_FETCH_SITE" = "same-origin" \
#test "$HTTP_SEC_FETCH_SITE" = "same-origin" || {
#  res 429 "Same origin" application/json '{"message":"Use same origin."}'
#}

now=signet25
rest=bublina.eu.org
myfull=$now.$rest
test "$HTTP_REFERER" = "https://$myfull/" \
  -a "$HTTP_HOST" = "$myfull" \
  -a "$HTTP_REFERER" = "https://$HTTP_X_FORWARDED_HOST/" \
  || {
  res 429 "Try again" application/json '{"message":"Try again. Here is the other cheek."}'
}

test "$cfts" = "" && {
  res 400 "Wait for turnstile"
}
xff=${HTTP_X_FORWARDED_FOR%%,*}
xip=${xff:-"$REMOTE_ADDR"}
# Set the directory where the rate-limiting data is stored.
# It can be overriden by a global inherited environment variable.
WHERE=${WHERE:-/tmp/faucet}
# Set the file name used for rate-limiting.
LIMIT=$WHERE/.limit/${xip%:*:*:*:*:*}
uuid=$(uuidgen)

# Pre-set Site-key and Secret-key to always-blocking dummy ones from
# https://developers.cloudflare.com/turnstile/troubleshooting/testing/
sitkey=2x00000000000000000000AB
seckey=2x0000000000000000000000000000000AA
# Override the pre-set keys now if file exists
. ~/.cfts
curl -sSL 'https://challenges.cloudflare.com/turnstile/v0/siteverify' \
  --data "secret=$seckey&response=$cfts&remoteip=$xip&idempotency_key=$uuid" \
  | tr -d " " | grep -q '"success":true,' || {
  res 429 "Not good" application/json '{"message":"Not good. Here is the other cheek."}'
  }
set cftsOK=1
#printenv | safecat.sh /tmp/GETenv

test "$address" = "" && {
  res 400 "Empty address" application/json '{"message":"Empty address"}'
}

# Early invalid address detection just using grep
# does not leave any trace of the invalid address
echo "$address" | grep -qE '^(tb1pfees9rn5nz|tb1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{39}|tb1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{59}|[mn2][a-km-zA-HJ-NP-Z1-9]{25,34})$' || {
  res 400 "Invalid address" application/json '{"message":"Invalid address"}'
}
#cd ~/.bitcoin/signet
#viraddr.sh $address 2>/dev/null || {
#  res 429 "Used address" application/json '{"message":"Used address. Find a new virgin one."}'
#}

# Left for backward API compatibility, the amount is ignored further
#amount=${amount:-0.0001}
#amount=${amount##0.}
#amount=0.${amount##.}
# Early invalid amount detection
#echo "$amount" | grep -qE '^0{0,1}\.[01][0-9]{0,7}$' || {
#  res 400 "Invalid amount" application/json '{"message":"Invalid amount"}'
#}

# Make sure the amount makes sense early enough as it is a simple
# computation not requiring any external binary.
#amsat=$(echo $amount*100000000 | bc | cut -d. -f1)
#test $amsat -le 10000000 -a $amsat -ge 10000 || {
#  res 400 "Out of bounds" application/json \
#    '{"message":"Amount out of boundaries"}'
#}

# Supplied amount is ignored and set to a random value starting with 0.00
# at least 5000 satoshi (500 minimum is 0.0000500 == 0.00005000)
# $RANDOM maximum value seems to be 5 digits long so add one more zero
#amount=0.0$(printf "%04d" $((($RANDOM%9999) + 500)))000
#amount=0.00075000

# Checking address with bitcoin-cli in this stage should be pretty
# cheap as all totally invalid addresses are already ruled out
# and we make sure that space is saved by not allowing to create
# unlimited number of directories which would pass the regex rule
# but would be actually invalid addresses.
#bitcoin-cli -signet validateaddress $address | grep -q Invalid && {
#  res 400 "Invalid address" application/json '{"message":"Invalid address"}'
#}


# Directory containing directories with used addresses
# Should be regularly cleaned
USADDR=${USADDR:-"$WHERE/usaddr"}
op=${address%${address#?}}
test "$op" = "t" && op=${address%${address#????}}
ADLOCK=$USADDR/$op/${address##${op}}
rm -rf $USADDR/tbp1/fees*
oxff=$HTTP_X_FORWARDED_FOR
#xff=${HTTP_X_FORWARDED_FOR##*, }
#echo $HTTP_X_FORWARDED_FOR >&2
#HTTP_X_REAL_IP=${HTTP_X_FORWARDED_FOR:-"$REMOTE_ADDR"}
#HTTP_X_REAL_IP=${HTTP_X_REAL_IP:-"$REMOTE_ADDR"}
#HTTP_X_REAL_IP=${HTTP_CF_CONNECTING_IP:-"$REMOTE_ADDR"}


read -r myip < /tmp/myip
myip=${myip:-"1234567890"}
test \
	"${xip%.*.*}" = "192.168" \
	-o "$xip" = "127.0.0.1" \
	-o "$xip" = "$myip" \
	&& {
  #echo Exception $ADLOCK $xip
  rm -rf \
    $LIMIT \
    $ADLOCK $WHERE/.limit/192.168* $WHERE/.limit/127.0.0.1 $WHERE/.limit/$myip
}
mkdir -p ${ADLOCK%/*}
mkdir $ADLOCK 2>/dev/null || { test -d $ADLOCK && touch $ADLOCK; AA=1; }
#set | safecat.sh /tmp/setmy

#torcheck.sh $xip || {
#  res 400 "Notorious" application/json '{"message":"Use a public IP"}'
#}

mkdir -p ${LIMIT%/*}
mkdir $LIMIT 2>/dev/null || {
  test -d $ADLOCK && touch $ADLOCK
  test -d $LIMIT && touch $LIMIT
  echo $xip 429 >&2
  res 429 "Slow down" application/json '{"message":"Please slow down"}'
}

test -d $ADLOCK && touch $ADLOCK
test -d $LIMIT && touch $LIMIT

test "$AA" = "1" && {
  res 429 "Another address" application/json \
    '{"message":"Use another address"}'
}

limit=/tmp/faucet/signetlimit
test -r $limit && {
  echo $xip wait >&2
  rmdir $ADLOCK $LIMIT 2>/dev/null
  res 400 "Wait a block"
}

echo $xip >&2
#cd ${WALLETDIR:-$HOME/.bitcoin/signet/wallets/newnew}
cd $HOME/.bitcoin/signet/wallets/newnew
#restofline="txid $(wosh faucet $address | grep .)" \
#signetfaucet.sh $address
#exit 0
restofline=$(signetfaucet.sh $address | grep .) \
|| {
  #grep -qw ancestors /tmp/sf && touch $limit
  res 400 "Something wrong" text/html "Something went wrong"
} && {
  res 200 OK text/html "Random payment will be sent to $restofline"
} # restofline
