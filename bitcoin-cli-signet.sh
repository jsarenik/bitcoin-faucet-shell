bitcoin-cli -signet -named sendtoaddress \
  address=tb1pc6rlswtdgsadws4ltj7juxgae7mfhm6ytgwwdnfsv8m0wgehaf4sgac7uw \
  amount=${1:-0.001} \
  subtractfeefromamount=false \
  replaceable=true \
  avoid_reuse=false \
  fee_rate=1
