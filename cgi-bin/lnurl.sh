#!/busybox/sh

a="/$0"; a=${a%/*}; a=${a:-.}; a=${a#/}/; HERE=$(cd $a; pwd)
PATH=/busybox:$PATH

#set > /tmp/myset-$$

test "$QUERY_STRING" = "" \
  || {
    eval $(echo "$QUERY_STRING" | grep -o '[a-zA-Z]\+=[0-9a-zA-Z\.]\+')
  }

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

test "$amount" = "" && {
  res 400 "Amount not specified." text/plain 'Empty amount'
}

mkdir $LIMIT 2>/dev/null || {
  cat $LIMIT/data
  #res 429 "Slow down" text/plain 'Please slow down'
  exit
}
myexit() {
  nohup sh -c "cd $HOME/.lightning; lch.sh waitinvoice "$label"; rm -rf $LIMIT" \
    </dev/null >/dev/null 2>&1 &
}

trap myexit EXIT

cd $HOME/.lightning

while
  label="lnurl-generated-$RANDOM"
do
  lch.sh listinvoices "$label" | grep label || break
done

test "$comment" = "" || label="$label-$comment"
TY="Thank you!"
test "$comment" = "" || TY="$TY $comment"

PR=$(lch.sh invoice "$amount" "$label" "$TY" | jq -r .bolt11) || {
  res 400 "Something wrong" text/plain "Something went wrong"
}
#ROUTES=$(lch.sh decode $PR | jq -c .routes)

{
cat <<EOF
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{"pr":"$PR"}
EOF
#{"status":"OK","routes":$ROUTES,"pr":"$PR"}
} | tee $LIMIT/data
