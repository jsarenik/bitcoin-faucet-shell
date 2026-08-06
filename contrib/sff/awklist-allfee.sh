#!/bin/sh

net=$(hnet.sh)
faucet=tb1p4tp4l6glyr2gs94neqcpr5gha7344nfyznfkc8szkreflscsdkgqsdent4
feerate=1000
fee=141
add=0
addrout=$faucet
test "$1" = "-d" && { addrout=$2; shift 2; }
test "$1" = "-o" && { addrout=$2; shift 2; }
test "$1" = "-f" && { fee=$2; shift 2; }
test "$1" = "-fm" && { feerate=1000; shift; }
message="on signet we learn"
message="please consider rebasing Inquisition to v29.0 and mine zero outputs on signet"
message="everything's fine | On signet we learn."
test "$(date +%w)" = "5" && message="שבת שלום"
test "$net" = "main" && message="strike.me"
test "$net" = "main" && message="cfpages-limits.pages.dev"
test "$net" = "main" && message="Bitcoin Army #pardonsamourai"

test "$1" = "-m" && { message=$2; shift 2; }
message=$(printf "%s" "$message" | busybox hexdump -ve '1/1 "%02x"' | grep .)

awk "{sum+=\$3; print \$1\":\"\$2} END {sum-=($fee*$feerate+$add)/100000000; printf(\"data,\\\"$message\\\"\n\"); }"
