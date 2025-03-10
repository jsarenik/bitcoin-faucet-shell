#!/bin/sh

addrout=tb1qxg0f4wepvpx5x8n4pjx587qh282e752806gn20
addrout=tb1pj7th9ylveltll9z8dksk6d9tv3jxn4mzp0rlh90h7txgleugqh0qjpnfze
addrout=tb1pupx8xare6jwl87nu058lc4ckqrrd3ugd9q6czxz9my8c49s085pq54ayff
addrout=tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn # signet faucet
faucet=tb1p4tp4l6glyr2gs94neqcpr5gha7344nfyznfkc8szkreflscsdkgqsdent4 # signet faucet
feerate=1
fee=141
add=1
gmm=$(gmm.sh)
gmm=${gmm:-1000}
test "$1" = "-f" && { fee=$2; shift 2; }
test "$1" = "-d" && { addrout=$2; shift 2; }
test "$1" = "-f" && { fee=$2; shift 2; }
test "$1" = "-fr" && { gmm=1000; shift; }
#test "$1" = "-m" && { message=$2; shift 2; }
message="NOTE: This is a test network. Coins have no value."
message=$(printf "%s" "$message" | xxd -p | tr -d '\n')
amount=$(echo 1${RANDOM}0000000 | cut -b-7)
amount=$(($amount/2+($RANDOM%149)))
test "$1" = "-a" && { amount=$2; shift 2; }

awk "{sum+=\$3; print \$1\":\"\$2} END {sum-=(((($fee*$gmm*2)+999)/1000)+$add)/100000000; printf(\"$faucet,%8f\n$addrout,%.8f\n\", sum-($amount/100000000), $amount/100000000); }" ${1}

#awk "{sum+=\$3; print \$1\":\"\$2} END {sum-=((($fee*$feerate)+999)/1000+$add)/100000000; printf(\"$addrout,%.8f\ndata,\\\"$message\\\"\n\", sum); }" ${1}
#awk "{sum+=\$3; print \$1\":\"\$2} END {sum-=($fee*$feerate+$add)/100000000; printf(\"$addrout,%.8f\n$faucet,%.8f\ndata,\\\\"5468697320697320612074657374206e6574776f726b2e20436f696e732068617665206e6f2076616c75652e\\\\"\n\", $amount/100000000, sum-($amount/100000000)); }" ${1}
#awk "{sum+=\$3; print \$1\":\"\$2} END {sum-=(($fee*$feerate*$gmm/1000)+$add)/100000000; printf(\"$faucet,%8f\n$addrout,%.8f\ndata,\\\"616e642061206861707079206e6577207965617221\\\"\n\", sum-($amount/100000000), $amount/100000000); }" ${1}
## message awk "{sum+=\$3; print \$1\":\"\$2} END {sum-=($fee*$feerate+$add)/100000000; printf(\"$addrout,%.8f\n$faucet,%.8f\ndata,\\\"$message\\\"\n\", 0.00003500, sum-0.00003500); }" ${1}
### Padawan awk "{sum+=\$3; print \$1\":\"\$2} END {sum-=($fee*$feerate+$add)/100000000; printf(\"$addrout,%.8f\ndata,\\\"$message\\\"\ntb1qet6a6jjdpmd45mxjcmhgje94txtehzxpmh7pxq,1.23456789\", sum-1.23456789); }" ${1}
#awk "{sum+=\$3; print \$1\":\"\$2} END {sum-=($feerate+$add)/100000000; printf(\"$addr1,%.8f\n\", sum); }" list
