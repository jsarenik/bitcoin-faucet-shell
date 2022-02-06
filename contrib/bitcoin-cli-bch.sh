#!/bin/sh

PATH=$PWD:$PATH
cd ${1:-$HOME/.bitcoin/signet}
bch.sh -named sendtoaddress \
  address=tb1pc6rlswtdgsadws4ltj7juxgae7mfhm6ytgwwdnfsv8m0wgehaf4sgac7uw \
  amount=${2:-0.001} \
  subtractfeefromamount=false \
  replaceable=true \
  avoid_reuse=false \
  fee_rate=1
