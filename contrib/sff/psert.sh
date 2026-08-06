#!/bin/sh

BN=89999115000

test "$1" = "-q" && { add="2>/dev/null"; shift; }
{ test "$1" = "" && cat || echo $1; } \
| while read line; do
txid=$(bitcoin-tx -txid $line)
bch.sh prioritisetransaction "$txid" "0.0" $BN
{
echo $line
echo 0
} | eval bch.sh -stdin sendrawtransaction $add \
  || bch.sh prioritisetransaction "$txid" "0.0" -$BN
done

#exit
# optiontal clean-up would mess up logs so maybe exit before here
bitcoin-cli getprioritisedtransactions \
  | grep -e '^  "' -e '"fee_delta":' \
  | tr -d ' {,' | paste -d" " - - \
  | sed 's/"fee_delta":/"0.0" +/' \
  | sed 's/+-//' | tr '+' '-' | tr -d : \
  | xargs -n 3 -P 20 bitcoin-cli prioritisetransaction \
    >/dev/null 2>&1
