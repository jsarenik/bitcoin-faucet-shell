#!/bin/sh

addrout=tb1qxg0f4wepvpx5x8n4pjx587qh282e752806gn20
addrout=tb1pj7th9ylveltll9z8dksk6d9tv3jxn4mzp0rlh90h7txgleugqh0qjpnfze
addrout=tb1pupx8xare6jwl87nu058lc4ckqrrd3ugd9q6czxz9my8c49s085pq54ayff
addrout=tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn
faucet=tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn # signet faucet
faucet=tb1p4tp4l6glyr2gs94neqcpr5gha7344nfyznfkc8szkreflscsdkgqsdent4 # signet faucet
fee=141
add=0
gmm=$(gmm-gen.sh)
gmm=${gmm:-1000}
feerate=$(($gmm*11/3))
test "$1" = "-f" && { fee=$2; shift 2; }
test "$1" = "-fr" && { feerate=1000; shift; }
test "$1" = "-o" && { faucet=$2; shift 2; }
test "$1" = "-d" && { faucet=$2; shift 2; }
#amount=$(echo 6${RANDOM}${RANDOM} | cut -b-5)
#amount=$(($amount+$RANDOM))

awk "{sum+=\$3; print \$1\":\"\$2} END {sum-=(($fee*$feerate/1000)+$add)/100000000; printf(\"$faucet,%.8f\n\", sum); }"
#${1}
