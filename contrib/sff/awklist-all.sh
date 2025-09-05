#!/bin/sh

addrout=tb1qxg0f4wepvpx5x8n4pjx587qh282e752806gn20
addrout=tb1pj7th9ylveltll9z8dksk6d9tv3jxn4mzp0rlh90h7txgleugqh0qjpnfze
addrout=tb1pupx8xare6jwl87nu058lc4ckqrrd3ugd9q6czxz9my8c49s085pq54ayff
addrout=tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn
faucet=tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn # signet faucet
faucet=tb1p4tp4l6glyr2gs94neqcpr5gha7344nfyznfkc8szkreflscsdkgqsdent4 # signet faucet
vsize=141
add=0
gmm=$(gmm.sh)
gmm=${gmm:-1000}
#gmm=$(($gmm*4))
#test $gmm -gt 5000 && gmm=5000
#feerate=$(($gmm*42/3))
feerate=$(($gmm*16/13))
test "$1" = "-f" && { vsize=$2; shift 2; }
test "$1" = "-fr" && { feerate=$gmm; shift; }
test "$1" = "-fm" && { feerate=1000; shift; }
test "$1" = "-o" && { faucet=$2; shift 2; }
test "$1" = "-d" && { faucet=$2; shift 2; }
#amount=$(echo 6${RANDOM}${RANDOM} | cut -b-5)
#amount=$(($amount+$RANDOM))

awk "{sum+=\$3; print \$1\":\"\$2} END {sum-=(($vsize*$feerate/1000)+$add)/100000000; printf(\"$faucet,%.8f\n\", sum); }"
#${1}
