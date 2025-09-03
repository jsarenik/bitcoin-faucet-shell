#!/bin/sh
a="/$0"; a="${a%/*}"; a="${a:-.}"; a="${a##/}/"; BINDIR=$(cd "$a" || true; pwd)

test "$1" = "-c" && { conf=$2; shift 2; }
test "$conf" = "" || . $conf
fdir=${fdir:-/tmp}
sdi=${sdi:-$HOME/.bitcoin/signet}

lock=$fdir/locksff
mkdir $lock || exit 1

signetfaucet.sh -n

l=$fdir/mylist
errf=$fdir/sff-err
nusff=$fdir/nosff
sfl=$fdir/sfflast
shf=$fdir/sffhex
phf=$fdir/sffphf
pkf=$fdir/sffpkf
myp=$sdi/wallets
dent=tb1p4tp4l6glyr2gs94neqcpr5gha7344nfyznfkc8szkreflscsdkgqsdent4
otra=tb1pfp672fs37lpjx08gvva8nwh2t048vr8rdvl5jvytv4de9sgp6yrq60ywpv
xdna=tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn
feea=tb1pfees9rn5nz

. /dev/shm/UpdateTip-signet
hold=$height

mymv() {
  all=$*
  last=${all##* }
  from=${all% *}
  from=${from:-/dev/null}
  to=${last:-/dev/null}
  find $from -maxdepth 1 -type f \
    | xargs mv -t $to 2>/dev/null
}

sertl() {
  : > $errf
  : > $sfl
  {
  cat
  echo 0.21
  } | bch.sh -rpcclienttimeout=9 -stdin sendrawtransaction \
      2>$errf >$sfl
}

myexit() {
  ret=${1:-$?}
  d=$fdir/sffrest
  #test -s $sfl && cat $sfl
  test "$ret" = "0" && {
    mymv $fdir/sff $fdir/sff-s2
  } || {
    mymv $fdir/sff $fdir/sffrest
  }
  mymv $fdir/sff-s2 $fdir/sff-s3
  ls -1 "$d" | wc -l | safecat.sh /dev/shm/sffrest.txt
  myrest=$(ls -1 $fdir/sffrest/ | wc -l)
  myst=$(ls -1 $fdir/sff-s3/ | wc -l)
  echo rest $myrest stage3 $myst >&2

  echo ${2:-"SUCCESS $ret"} >&2
  rmdir $lock 2>/dev/null
  exit $ret
}

cd $myp
bch.sh echo hello | grep -q . || myexit 1 "early bitcoin-cli echo hello"

# are we online?
ping -qc1 1.1.1.1 2>/dev/null >&2 || myexit 1 offline

dothetf() {
cd $myp/newnew
list.sh | grep -v " 0 false$" | sort -rn -k3 | safecat.sh $l
cd $myp

gmm-gen.sh
lpr=$fdir/l123p
rm -rf $lpr
cd $myp/newnew
  fee=$(awklist-all.sh -d $dent < $l \
    | mktx.sh | crt.sh | srt.sh | fee.sh)
  echo $fee > $fdir/fee
  awklist-all.sh -f $fee -d $dent < $l  \
    | mktx.sh | crt.sh | srt.sh | safecat.sh $shf
  sertl <$shf
  read -r last < $sfl

until
  cd $myp/newnew
  list.sh | grep -q "^$last"
do
  usleep 21
done

for i in $(seq 25)
do
  test -s "$lpr" && {
  until
    cd $myp/newnew
    list.sh | grep " true$" | safecat.sh $l
    ! cmp $l $lpr
  do
    usleep 21
  done
  }
  . /dev/shm/UpdateTip-signet
  test "$hold" = "$height" || break
  cd $myp/newnew
  fee=$(awklist-all.sh -d $otra < $l \
    | mktx.sh | crt.sh | srt.sh | fee.sh)
  awklist-all.sh -f $fee -d $otra < $l  \
    | mktx.sh | crt.sh | srt.sh | safecat.sh $shf
  sertl <$shf
  grep -q . $sfl || break
  cp $l $lpr
done
}

##############################
### from blocknotify-signet.sh
rmdir $fdir/sffnewblock 2>/dev/null && {
d=$fdir/sffrest
mkdir -p $d
mymv $fdir/sff $d

cd $myp/newnew
list.sh | grep "[1-9] true$" | sort -rn -k3 | safecat.sh $l
cd $myp

# was: clean-sff.sh
tx=$(cat $l | head -1 | grep .) || myexit 1 "EARLY newblock tx"
txid=${tx%% *}
cd $myp/newnew
  bch.sh gettransaction $txid | jq -r .details[].address \
    | sort -u | safecat.sh $fdir/sffgt
cd $myp
rm -rf $fdir/sff-s3/0*
d=$fdir/sffrest
cd $d
mymv $fdir/sff-s2 $fdir/sff-s3 $d
  cat $fdir/sffgt | xargs rm -rf

dothetf



cd $myp
#signetcatapultleftovers.sh

test -d $fdir/sffnewblock && myexit 1 "new block again"

d=$fdir/sffrest
mymv $fdir/sff $d
cd $d
  ls -1 "$d" \
    | head -n 1800 | xargs mv -t $fdir/sff
}
##############################
##############################
##############################

cd $myp/newnew || myexit 1 "early cd newnew"
list.sh | grep " 0 true$" | sort -rn -k3 | safecat.sh $l
cd $myp

printouts() {
  test ${1:-1} -lt 252 \
    && { hex ${1:-1} - 2 | grep .; } \
    || { printf "fd"; hex ${1:-1} - 4 | ce.sh; }
}

#set -o errexit
#set -o pipefail
#set +o pipefail
tx=$(head -1 $l | grep .) || myexit 1 "main loop tx issue"
tx=${1:-$tx}
txid=${tx%% *}

test "$txid" = "" && myexit 1 "empty TXID"
echo "$txid" | grep -E '[0-9a-f]{64}' || myexit 1 "strange TXID"

gmef=$fdir/sff-gme
gmep=$fdir/sff-gme.sh
gtof=$fdir/sff-gtot

hf=$fdir/replnhex
: > $hf
grt.sh $txid | safecat.sh $hf
test -s "$hf" || { dothetf; myexit 1 "grt dothetf"; }
sertl < $hf
grep '^03' $hf && myexit 1 "V3 no more"

: > $gmep
: > $gmef
cd $myp
gme.sh $txid | safecat.sh $gmef
depends=$(jq -r .depends[0] < $gmef)
dce=$(echo $depends | ce.sh)
cd $myp/newnew
bch.sh gettransaction $depends \
  | grep -m1 '^      "amount": [0-9]' \
  | tr -d '{} \t",.' \
  | tr : = \
  | sed 's/=0\+/=/' \
  | safecat.sh $gtof
. $gtof
value=$amount
test -s "$gmef" || myexit 1 "missing $gmef"
#jq -r .spentby[] < $gmef | grep -q . && myexit 1 "FOREIGN CHILD SPEND"

tr -d '{} \t",.' < $gmef \
  | sed '/^depends/,$d' \
  | sed '/^fees/d; $d' | tr : = \
  | sed 's/=0\+/=/' \
  | safecat.sh $gmep

# sets vsize weight time height descendantcount descendantsize
# ancestorcount ancestorsize wtxid base modified ancestor descendant
. $gmep
test "$ancestorcount" = "25" || dothetf
test "$vsize" -lt 98299 || myexit 1 "early TOO BIG vsize $vsize"

outsum=$(($value-${base:-0}))
read -r txid < $sfl

# was: clean-sff.sh
tx=$(cat $l | head -1 | grep .) || myexit 1 "EARLY newblock tx"
txid=${tx%% *}

mkdir -p $fdir/sff-s2
mkdir -p $fdir/sff-s3

d=$fdir/sffrest
mkdir -p $d
randomone=$(($RANDOM%2))
ls -1 $fdir/sff/ | grep -q . || {
d=$fdir/sffrest
cd $d
  ls -1 2>/dev/null | head -n $((((98000-$vsize-51)/52)+$randomone)) \
    | xargs mv -t $fdir/sff/
}

find $fdir/sff/ $fdir/sff-s2/ $fdir/sff-s3/ -mindepth 1 -type f 2>/dev/null \
  | sort -u \
  | xargs cat \
  | safecat.sh $nusff

newouts=$(wc -l < $nusff)
test "$newouts" -ne "0" || myexit 1 "no new outputs"
max=$(cat $l | sum.sh | tr -d . | sed 's/^0\+//' | grep '^[0-9]\+$') \
  || myexit 1 "unknown max $max"
test $max -gt 330 || myexit 1 "low max $max"
new=$(($max/102/$newouts))
test "$new" -gt 330 || myexit 1 "new $new is too low"
rest=$(($max-$new*$newouts))

# needs $new and $nusff
of=$fdir/sff-outs
newh=$(hex $new - 16 | ce.sh | grep .) || myexit 1 "newh $newh"
cat $nusff | sed "s/^/$newh/" | safecat.sh $of


dotx() {
  . /dev/shm/UpdateTip-signet
  test "$hold" = "$height" || myexit 1 "$hold $height new block in the meantime"

  hhasum=$(($outsum + $base - ${max:-0} + $rest))
  echo $hhasum | grep -q -- - && myexit 1 "hhasum $hhasum"
  hha=$(hex $hhasum - 16 | ce.sh)
  echo 0200000001${dce}0000000000fdffffff
  printouts $((2+$newouts))
  echo $hha 22 5120aac35fe91f20d48816b3c83011d117efa35acd2414d36c1e02b0f29fc3106d90
  finta=$(printf " | %4d" $newouts | xxd -p)
  echo 00000000000000001d6a1b616c742e7369676e65746661756365742e636f6d $finta
  cat $of
  hex $height - 8 | ce.sh
}

feer() {
  # Fee-rate $abs_sats_fee $divisor_vsize
  mysats=$1
  mydiv=$2
  fr=$(((1000*$mysats+$mydiv-1)/$mydiv))
  echo $fr
}

feerl() {
  # Fee-rate (low end) $abs_sats_fee $divisor_vsize
  mysats=$1
  mydiv=${2:-100}
  fr=$((1000*$mysats/$mydiv))
  echo $fr
}

sats() {
  # Absolute_sats_fee $feer $divisor_vsize
  myfeer=$1
  mydiv=$2
  out=$(( (($myfeer*$mydiv)+999)/1000 ))
  echo $out
}

satsl() {
  # Absolute_sats_fee (low end) $feer $divisor_vsize
  myfeer=$1
  mydiv=$2
  out=$(($myfeer*$mydiv/1000))
  echo $out
}

########################################################
########################################################
########################################################

dvs=$vsize

cd $myp/newnew
dotx | safecat.sh $fdir/us

cd $myp/newnew
cat $fdir/us | txcat.sh | srt.sh | safecat.sh $shf
cd $sdi
vsizenew=$(fee.sh < $shf | grep .) || myexit 1 "missing vsizenew"
echo vsize $vsize vsizenew $vsizenew >&2
test $vsizenew -le 100000 || myexit 1 "TOO BIG"

#########################################################

dvs=$(( $vsizenew+$base ))
test "$vsizenew" = "$vsize" && myexit 1 "no change"
cd $myp/newnew
dotx | txcat.sh | srt.sh | safecat.sh $shf
cd $sdi

############
# stage 4
############

sats=$(( $base + $vsizenew ))
  ofeer=$(feer $base $vsize | grep .) || myexit 1 "ofeer $ofeer vsize $vsize"
  feer=$(feer $sats $vsizenew | grep .) || myexit 1 "feer $feer"
  test $feer -lt $ofeer && {
    sats=$(sats $(($ofeer+1)) $vsizenew)
  }
dvs=$sats

  new=1000
  test $max -gt 25991051601 && new=40000
  test $max -gt 35991051601 && new=80000
  test $max -gt 85991051601 && new=200000
  test $max -gt 105991051601 && new=300000
  test $max -gt 115991051601 && new=500000
  test $max -gt 125991051601 && new=1100000
  new=$(($new+$newouts))
  test "$new" -gt 330 || myexit 1 "at the end: new $new is too low"
  rest=$(($max-$sats-$new*$newouts))

# needs $new and $nusff
newh=$(hex $new - 16 | ce.sh | grep .) || myexit 1 "newh $newh"
cat $nusff | sed "s/^/$newh/" | safecat.sh $of

cd $myp/newnew
dotx | txcat.sh | srt.sh | safecat.sh $shf
cd $sdi
sertl <$shf
ret=$?
echo feer4 $feer sats $sats >&2
echo ofeer $ofeer feer $feer >&2
echo max $max fee-rate $feer base $base vsize $vsizenew >&2

myexit $ret "finn"
