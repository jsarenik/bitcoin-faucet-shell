#!/busybox/sh

a="/$0"; a=${a%/*}; a=${a:-.}; a=${a#/}/; HERE=$(cd $a; pwd)
PATH=/busybox:$PATH

amount=$1
desc=${2:-"reallyfromalby"}

while
  label="lnurl-generated-$RANDOM"
do
  lightning-cli listinvoices "$label" | grep label || break
done

PR=$({
cat <<EOF
{ "jsonrpc" : "2.0",
 "method" : "invoice",
 "id" : "lightning-cli-$RANDOM",
 "params" :{
   "msatoshi" : $amount,
   "label" : "$label",
   "deschashonly" : true,
   "description" : "[[\"text/plain\", \"$desc\"]]",
   "exposeprivatechannels" :  "728591x176x1"
 }
}
EOF
} | tr -d '\n' | /usr/bin/nc -U $HOME/.lightning/bitcoin/lightning-rpc \
  | sed 1q | jq -r .result.bolt11)
