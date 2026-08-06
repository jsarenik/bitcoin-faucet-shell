#!/bin/sh

addrout=tb1qxg0f4wepvpx5x8n4pjx587qh282e752806gn20
addrout=tb1pj7th9ylveltll9z8dksk6d9tv3jxn4mzp0rlh90h7txgleugqh0qjpnfze
addrout=tb1pupx8xare6jwl87nu058lc4ckqrrd3ugd9q6czxz9my8c49s085pq54ayff
addrout=tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn # signet faucet
faucet=tb1p4tp4l6glyr2gs94neqcpr5gha7344nfyznfkc8szkreflscsdkgqsdent4 # signet faucet
feerate=1
fee=141
add=0
#gmm=$(gmm.sh)
gmm=${gmm:-100}
test "$1" = "-f" && { fee=$2; shift 2; }
test "$1" = "-d" && { addrout=$2; shift 2; }
test "$1" = "-f" && { fee=$2; shift 2; }
test "$1" = "-fr" && { gmm=1000; shift; }
test "$1" = "-fm" && { feerate=1000; shift; }
test "$1" = "-m" && { message=$2; shift 2; }
message="NOTE: This is a test network. Coins have no value."
message=$(printf "%s" "$message" | xxd -p | tr -d '\n')
amount=$(echo 1${RANDOM}0000000 | cut -b-7)
amount=$(($amount/2+($RANDOM%149)))
test "$1" = "-a" && { amount=$2; shift 2; }

awk "{sum+=\$3; print \$1\":\"\$2} END {sum-=(((($feerate*$gmm)+99)/100)+$add)/100000000; printf(\"$faucet,%8f\n$addrout,%.8f\n\", sum-($amount/100000000), $amount/100000000); }" ${1}
