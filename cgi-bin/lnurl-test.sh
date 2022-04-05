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

{
printf '{"jsonrpc":"2.0","method":"invoice","id":"lightning-rpc-%d","params":{"msatoshi":%d,"label":"%s","deschashonly":true,"description":"[[\"text/identifier\", \"anyone@ln.anyone.eu.org\"], [\"text/plain\", \"anyone\"]]","exposeprivatechannels":"728591x176x1"}}' \
  $RANDOM$RANDOM \
  $amount \
  "$label"
} | /usr/bin/nc -U $HOME/.lightning/bitcoin/lightning-rpc \
  | head -1 | jq -r .result.bolt11

# Instead of netcat:
# | socat UNIX-CONNECT:$SOCK -
