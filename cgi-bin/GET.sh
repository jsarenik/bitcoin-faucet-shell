#!/bin/sh

res() {
  cat <<-EOF
	HTTP/1.1 $1 $2
	Content-Type: ${3:-application/json}; charset=utf-8

	${4:-$2}
	EOF
  test -d $sfs || rmdir ${LIMIT:-/tmp/nothing} 2>/dev/null
  exit
}

sfs=/tmp/sff-sfs
now=signet257
rest=bublina.eu.org
myfull=$now.$rest
#set | safecat.sh /tmp/GETset
echo "$HTTP_REFERER" | grep -q "^https://$myfull/" \
  && echo "$HTTP_REFERER" | grep -q "^https://$HTTP_X_FORWARDED_HOST/" \
  && test "$HTTP_HOST" = "$myfull" \
    -a "$HTTP_X_FORWARDED_HOST" = "$myfull" \
    -a "$HTTP_X_FORWARDED_PROTO" = 'https' \
    -a "$HTTP_CF_VISITOR" = '{"scheme":"https"}' \
  || {
  res 429 "Try again" application/json '{"message":"Try again. Here is the other cheek."}'
}

test "$cfts" = "" && {
  res 400 "Wait for turnstile"
}

xff=${HTTP_X_FORWARDED_FOR%%,*}
test "$xff" = "$HTTP_CF_CONNECTING_IP" \
  && xip=${xff:-"$REMOTE_ADDR"} \
  || res 429 "unknown address"

# Set the directory where the rate-limiting data is stored.
# It can be overriden by a global inherited environment variable.
WHERE=${WHERE:-/tmp/faucet}
# Set the file name used for rate-limiting.
LIMIT=$WHERE/.limit/${xip%:*:*:*:*:*}
mkdir -p ${LIMIT%/*}
#! mkdir $LIMIT 2>/dev/null \
#  && test -d $sfs && {
! mkdir $LIMIT 2>/dev/null && {
  echo $xip 429 >&2
  res 429 "Slow down" application/json '{"message":"Please slow down"}'
}

#uuid=$(uuidgen)

# Pre-set Site-key and Secret-key to always-blocking dummy ones from
# https://developers.cloudflare.com/turnstile/troubleshooting/testing/
sitkey=2x00000000000000000000AB
sitkey=1x00000000000000000000AA
seckey=2x0000000000000000000000000000000AA
seckey=1x0000000000000000000000000000000AA
# Override the pre-set keys now if file exists
#. ~/.cfts
sleep 1
#  --data "secret=$seckey&response=$cfts&remoteip=$xip&idempotency_key=$uuid" \
#  --data "secret=$seckey&response=$cfts" \
#test "${#cfts}" -gt 32 || res 429 "Too short cfts" application/json '{"message":"Too short turnstile response."}'
#curl -sSL 'https://challenges.cloudflare.com/turnstile/v0/siteverify' \
#curl -sSL 'https://challenges.cloudflare.com/turnstile/v0/siteverify' \
#  --data "secret=$seckey&response=$cfts&remoteip=$xip&idempotency_key=$uuid" \
#  | tr -d " " | grep -q '"success":true,' || {
#  res 429 "Not good" application/json '{"message":"Not good turnstile."}'
#  }
set cftsOK=1

test "$address" = "" && {
  res 400 "Empty address" application/json '{"message":"Empty address"}'
}

# Early invalid address detection just using grep
# does not leave any trace of the invalid address
echo "$address" | grep -qE '^(04[0-9a-f]{128}|0[23][0-9a-f]{64}|tb1pfees9rn5nz|tb1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{39}|tb1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{59}|[mn2][a-km-zA-HJ-NP-Z1-9]{25,34})$' || {
  res 400 "Invalid address" application/json '{"message":"Invalid address"}'
}


#
# IP exceptions
#
#
#read -r myip < /tmp/myip
#myip=${myip:-"1234567890"}
#test \
#	"${xip%.*.*}" = "192.168" \
#	-o "$xip" = "127.0.0.1" \
#	-o "$xip" = "$myip" \
#	&& {
#  rm -rf \
#    $LIMIT \
#    $WHERE/.limit/192.168* $WHERE/.limit/127.0.0.1 $WHERE/.limit/$myip
#}

#
# Limit 1 IP per signet block after reaching some amount (sfsn)
#  cleanup is done in blocknotify-signet.sh and simplereplnn.sh
#

test -d $LIMIT && touch $LIMIT

#limit=/tmp/faucet/signetlimit
#test -r $limit && {
#  echo $xip wait >&2
#  rmdir $LIMIT 2>/dev/null
#  res 400 "Wait a block"
#}

echo $xip >&2
cd ${WALLETDIR:-"$HOME/.bitcoin/signet/wallets/newnew"}
restofline=$(signetfaucet.sh $address | grep .) \
|| {
  #grep -qw ancestors /tmp/sf && touch $limit
  res 400 "Something wrong" text/html "Something went wrong"
} && {
  res 200 OK text/html "Random payment will be sent to $restofline"
} # restofline
