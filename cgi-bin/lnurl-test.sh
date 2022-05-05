#!/busybox/sh

a="/$0"; a=${a%/*}; a=${a:-.}; a=${a#/}/; HERE=$(cd $a; pwd)
PATH=/busybox:$PATH

amount=${1:-1000}
desc=${2:-"reallyfromalby"}

while
  label="lnurl-generated-$RANDOM"
do
  lightning-cli listinvoices "$label" | grep label || break
done

C=$(lightning-cli listchannels 728591x176x1 | jq .channels[].active | sort -u)
test "$C" = "true" && addchannel=',"exposeprivatechannels":"728591x176x1"'
username=${username:-"anyone"}
{
printf '{"jsonrpc":"2.0","method":"invoice","id":"lightning-rpc-%d","params":{"msatoshi":%d,"label":"%s","deschashonly":true,"description":"[\"text/plain\", \"%s\"]]"%s}}' \
  $RANDOM$RANDOM \
  $amount \
  "$label" \
  "$username" \
  $addchannel
} | /usr/bin/nc -U $HOME/.lightning/bitcoin/lightning-rpc \
  | head -1 | jq -r .result.bolt11

# Instead of netcat:
# | socat UNIX-CONNECT:$SOCK -
