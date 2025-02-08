#!/bin/sh

### async now
# was mkdir /tmp/signetfaucet || exit 1

faucetaddr=tb1pupx8xare6jwl87nu058lc4ckqrrd3ugd9q6czxz9my8c49s085pq54ayff 
faucetaddr=tb1p4tp4l6glyr2gs94neqcpr5gha7344nfyznfkc8szkreflscsdkgqsdent4
faucetaddr=tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn

mkdir -p /tmp/sff
addr=${1:-$faucetaddr}
test -r /tmp/sff/$addr && { echo $addr; exit; }
spk=$(gai.sh ${addr} | grep -w scriptPubKey | cut -d: -f2 | tr -d ' ",')
echo "$(hex $((${#spk}/2)) - 2) $spk" | safecat.sh /tmp/sff/$addr

# Just a historical lock, make sure it's not there
rmdir /tmp/signetfaucet 2>/dev/null || true

echo $addr
