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
cat <<EOF
{"jsonrpc":"2.0","method":"invoice","id":"lightning-rpc-$RANDOM$RANDOM","params":{"msatoshi":$amount,"label":"$label","deschashonly":true,"description":"[[\"text/identifier\", \"anyone@ln.anyone.eu.org\"], [\"text/plain\", \"anyone\"]]","exposeprivatechannels":"728591x176x1"}}
EOF
} | /usr/bin/nc -U $HOME/.lightning/bitcoin/lightning-rpc | head -1 \
  | jq -r .result.bolt11
# | socat -t0.4 UNIX-CONNECT:$SOCK -
