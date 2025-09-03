#!/bin/sh

addr1=${ADDR1:-test}
test -r a && read -r addr1 < a
export addr1

eval $(bch.sh scantxoutset abort) \
  && while bch.sh scantxoutset status | grep -q .; do sleep 1; done

bch.sh -t scantxoutset start '''["addr('$addr1')"]''' \
  | busybox tr -d '" ,' \
  | busybox grep '^\(txid\|vout\|amount\|confirmations\):' \
  | busybox cut -d: -f2 \
  | busybox paste -d" " - - - -
