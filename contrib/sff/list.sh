#!/bin/sh

bch.sh listunspent ${1:-0} \
  | grep -w -e txid -e vout -e amount -e confirmations -e safe \
  | tr -d ' ,"' \
  | cut -d: -f2 \
  | paste -d " " - - - - -
