#!/bin/sh

### async now
# was mkdir /tmp/signetfaucet || exit 1

faucetaddr=tb1pupx8xare6jwl87nu058lc4ckqrrd3ugd9q6czxz9my8c49s085pq54ayff 
faucetaddr=tb1p4tp4l6glyr2gs94neqcpr5gha7344nfyznfkc8szkreflscsdkgqsdent4
faucetaddr=tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn

mkdir -p /tmp/sff /tmp/sff-s2 /tmp/sff-s3 /tmp/sffrest
addr=${1:-$faucetaddr}
test -r /tmp/sff/$addr && { echo $addr; exit; }

# P2PK
echo $addr | grep -Eq '^[0-9a-f]+$' && {
  echo $addr | grep -Eq '^[0-9a-f]{66}$' || exit 1
  kl=$(printf "%02x" $((${#addr}/2)) )
  klp=$(printf "%02x" $((0x$kl+2)) )
  echo "$klp ${kl}${addr}ac" | safecat.sh /tmp/sffrest/$addr
  echo $addr
  exit 0
}

cd $HOME/.bitcoin/signet/wallets/ae
#spk=$(gai.sh ${addr} | grep -m1 '^  "scriptPubKey":' \
#  | grep -m1 '^  "scriptPubKey":' \
#  | cut -d: -f2 | tr -d ' ",' | grep .) \
spk=$(hh.sh address inspect ${addr} \
  | grep -m1 '^    "hex": ' \
  | cut -d: -f2 | tr -d ' ",' | grep .) \
  && { echo "$(hex $((${#spk}/2)) - 2) $spk" | safecat.sh /tmp/sffrest/$addr; }

# Just a historical lock, make sure it's not there
rmdir /tmp/signetfaucet 2>/dev/null || true

echo $addr
