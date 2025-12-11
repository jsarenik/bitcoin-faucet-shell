#!/bin/sh

### async now
# was mkdir /tmp/signetfaucet || exit 1

test "$1" = "-c" && { conf=$2; shift 2; }
test "$conf" = "" || . $conf
fdir=${fdir:-/tmp}
sdi=${sdi:-$HOME/.bitcoin/signet}
myp=$sdi/wallets

faucetaddr=tb1pupx8xare6jwl87nu058lc4ckqrrd3ugd9q6czxz9my8c49s085pq54ayff 
faucetaddr=tb1p4tp4l6glyr2gs94neqcpr5gha7344nfyznfkc8szkreflscsdkgqsdent4
faucetaddr=tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn

mkdir -p $fdir/sff $fdir/sff-s2 $fdir/sff-s3 $fdir/sffrest
addr=${1:-$faucetaddr}
test -r $fdir/sff/$addr && { echo $addr; exit; }

test -d $fdir/_toomany && exit 1
sfs=$fdir/sff-sfs # sff-flag-slowdown
sfm=$fdir/sff-sfm # max
sfo=$fdir/sff-sfo # overall
sfsn=2016
sfsm=4032
sfso=6079
read -r newouts < $fdir/newouts
test $newouts -gt $sfsn && mkdir -p $sfs || rm -rf $sfs
test $newouts -gt $sfsm && mkdir -p $sfm || rm -rf $sfm
test $newouts -gt $sfso && mkdir -p $sfo || rm -rf $sfo

test "$1" = "-n" && exit

grep -qF "$addr" $myp/addresses-* \
  && exit 1

# P2PK
echo $addr | grep -Eq '^[0-9a-f]+$' && {
  echo $addr | grep -Eq '^[0-9a-f]{66}$' \
    || echo $addr | grep -Eq '^[0-9a-f]{130}$' \
    || exit 1
  kl=$(printf "%02x" $((${#addr}/2)) )
  klp=$(printf "%02x" $((0x$kl+2)) )
  echo "$klp ${kl}${addr}ac" | safecat.sh $fdir/sffrest/$addr
  echo $addr
  exit 0
}

# ae stands for always empty
cd $myp/ae
spk=$(hh.sh address inspect ${addr} \
  | grep . \
  | grep -m1 '^    "hex": ' \
  | cut -d: -f2 | tr -d ' ",' | grep .) \
  && { echo "$(hex $((${#spk}/2)) - 2) $spk" | nicecat.sh $fdir/sffrest/$addr \
  | grep -q . && echo $addr; }

# Just a historical lock, make sure it's not there
rmdir $fdir/signetfaucet 2>/dev/null || true
