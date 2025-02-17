#!/busybox/sh

a="/$0"; a=${a%/*}; a=${a:-.}; a=${a#/}/; HERE=$(cd $a; pwd)
PATH=/busybox:$PATH

test "$QUERY_STRING" = "" \
  || {
    eval $(echo "$QUERY_STRING" | grep -o '[a-zA-Z]\+=[0-9a-zA-Z +\.]\+' \
             | tr '+' ' ' | sed 's/=\(.*\)/="\1"/')
  }

#set > /tmp/myset-$$

WHERE=${WHERE:-/tmp/faucet}

# HTTP_X_REAL_IP is the HTTP header set in Caddyfile, falling back
# to the contents of REMOTE_ADDR variable set by busybox httpd
# if not set by the proxying web server.
HTTP_X_REAL_IP=${HTTP_X_REAL_IP:-"$REMOTE_ADDR"}

# Set the file name used for rate-limiting.
LIMIT=$WHERE/.lnurl/$(echo $HTTP_X_REAL_IP | cut -d: -f1-3 | tr -d '.:\[\]')

res() {
  cat <<-EOF
	HTTP/1.1 $1 $2
	Content-Type: $3; charset=utf-8

	$4
	EOF
#  mkdir $LIMIT \
#    && nohup sh -c "sleep $(((RANDOM%60)+45)); rmdir $LIMIT" \
#      </dev/null >/dev/null 2>&1 &
  exit
}

# LN address: name@domain
# https://domain/.well-known/lnurlp/name
#
test "$amount" = "" && {
  res 400 "Amount not specified." text/plain 'Empty amount'
}

mkdir $LIMIT 2>/dev/null || {
  res 429 "Slow down" text/plain 'Please slow down'
}

myexit() {
  nohup sh -c "timeout 5900 lightning-cli waitinvoice "$label"; rm -rf $LIMIT" \
    </dev/null >/dev/null 2>&1 &
}

cd $HOME/.lightning
SOCK=$HOME/.lightning/bitcoin/lightning-rpc

while
  label="lnurl-generated-$RANDOM$RANDOM"
do
  lightning-cli listinvoices "$label" | grep label || break
done

trap myexit EXIT

test "$comment" = "" || { label="$label"; desc="$comment"; }

unset addchannel
# If there is a private channel which you want to advertise
#C=$(lightning-cli listchannels 728591x176x1 | jq .channels[].active | sort -u)
#test "$C" = "true" && addchannel=',"exposeprivatechannels":"728591x176x1"'
username=${username:-"anyone"}
PR=$({
printf '{"jsonrpc":"2.0","method":"invoice","id":"lightning-rpc-%d","params":{"msatoshi":%d,"label":"%s","deschashonly":true,"description":"[[\"text/plain\", \"%s\"]]"%s}}' \
  $RANDOM$RANDOM \
  $amount \
  "$label" \
  "$username" \
  $addchannel
} | /usr/bin/nc -U $SOCK \
  | head -1 | jq -r .result.bolt11) || {
  res 400 "Something wrong" text/plain "Something went wrong"
}

{
cat <<EOF
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{"pr":"$PR","routes": []}
EOF
} | tee $LIMIT/data
