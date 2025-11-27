#!/bin/sh
a="/$0"; a="${a%/*}"; a="${a:-.}"; a="${a##/}/"; BINDIR=$(cd "$a" || true; pwd)

##########################################################################

# optional configuration file (see signetfaucet.conf)
test "$1" = "-c" && { conf=$2; shift 2; }
test "$conf" = "" || { test -r $conf && . $conf; }
fdir=${fdir:-/tmp}
sdi=${sdi:-$HOME/.bitcoin/signet}

# lock file, used also by refreshsignetwallets.sh
lock=$fdir/locksff
mkdir $lock || exit 1

signetfaucet.sh -n
#gmm-gen.sh is in blocknotify-signet.sh now

l=$fdir/mylist
errf=$fdir/sff-err
nusff=$fdir/nosff
sfl=$fdir/sfflast
shf=$fdir/sffhex
phf=$fdir/sffphf
pkf=$fdir/sffpkf
myp=$sdi/wallets
net=$(cd $myp; hnet.sh)
wd=$myp/newnew
dent=tb1p4tp4l6glyr2gs94neqcpr5gha7344nfyznfkc8szkreflscsdkgqsdent4
otra=tb1pfp672fs37lpjx08gvva8nwh2t048vr8rdvl5jvytv4de9sgp6yrq60ywpv
xdna=tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn
feea=tb1pfees9rn5nz
gmef=$fdir/sff-gme
gmep=$fdir/sff-gme.sh
gtof=$fdir/sff-gtot
lpr=$fdir/l123p

##########################################################################

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
  {
  cat
  echo 0.21
  } | bch.sh -rpcclienttimeout=9 -stdin sendrawtransaction \
      2>$errf | safecat.sh $sfl
}

myexit() {
  ret=${1:-$?}
  d=$fdir/sffrest
  test -s $sfl && cat $sfl
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

mylist() {
  bch.sh listunspent ${1:-0} \
    | grep -w -e txid -e vout -e amount -e confirmations -e safe \
    | tr -d ' ,"' \
    | cut -d: -f2 \
    | paste -d " " - - - - -
}

doinit() {
  cd $wd
  #mylist | grep -v " 0 [tf][a-z]\+$" | grep " true$" | sort -rn -k3
  mylist | grep " true$" | sort -rn -k3
  cd $myp
}

doinito() {
  : > $l
  doinit | safecat.sh $l
}

dolist() {
  cd $wd
  mylist | grep " 0 true$" | sort -rn -k3
  cd $myp
}

dolisto() {
  : > $l
  dolist | safecat.sh $l
}

catapultleftovers() {
  tmpc=$(mktemp /dev/shm/catapultleft-$net-XXXXXX) || exit 1
  list=$tmpc
  lh=${list}-hex

  : > $list
  cd $wd
  mylist | grep " 0 false$" | safecat.sh $list
  test -s $list || return
  num=$(wc -l < $list)
  cd $wd

  cat $list | awk '($3<=0.01){print $1, $2, $3}' \
    | awklist-allfee.sh \
    | mktx.sh | crt.sh | srt.sh | sert.sh
  rm -rf ${tmpc}* > /dev/null
}

isnewb() {
  cd $wd
  mylist | grep ' [^0]+ true$'
}

isoldb() {
  cd $wd
  mylist | grep ' 0 true$'
}

printouts() {
  test ${1:-1} -lt 252 \
    && { hex ${1:-1} - 2 | grep .; } \
    || { printf "fd"; hex ${1:-1} - 4 | ce.sh; }
}

gengmep() {
  : > $gmep
  : > $gmef
  cd $myp
  gme.sh $txid | safecat.sh $gmef
  tr -d '{} \t",.' < $gmef \
    | sed '/^depends/,$d' \
    | sed '/^fees/d; $d' | tr : = \
    | sed 's/=0\+/=/' \
    | safecat.sh $gmep
}

getamount() {
  cd $wd
  bch.sh gettransaction $depends \
    | grep -m1 '^      "amount": [0-9]' \
    | tr -d '{} \t",.' \
    | tr : = \
    | sed 's/=0\+/=/' \
    | safecat.sh $gtof
  . $gtof
  echo $amount
}

dotx() {
  hha=$(hex ${hhasum:-0} - 16 | ce.sh)
  echo 0200000001${dce}0000000000fdffffff

  printouts $((2+$newouts)) # increment outputs when enabling more

  echo $hha 22 5120aac35fe91f20d48816b3c83011d117efa35acd2414d36c1e02b0f29fc3106d90

  #echo 40420f0000000000
  #echo 22 51207160b81728928041c1e339dfa8faeeae44225c143d1c77fd5ca339416a4a7e3a

  msg=$(printf "alt.signetfaucet.com | %4d | " $newouts | xxd -p)
  msg="${msg}$hashe"
  lend=$((${#msg}/2))
  len=$(printf "%02x" $lend)
  leno=$(printf "%02x" $(($lend+2)))
  echo 0000000000000000 $leno 6a$len $msg

  #orl.sh "Please recycle"

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

sats() {
  # Absolute_sats_fee $feer $divisor_vsize
  myfeer=$1
  mydiv=$2
  out=$(( (($myfeer*$mydiv)+999)/1000 ))
  echo $out
}

##########################################################################

hashe="76$(sha256sum $0 | cut -b 59-64)"

# Early checks

## Is bitcoind talking RPC to us (from the wallet dir)?
cd $myp
bch.sh echo hello | grep -q . || myexit 1 "early bitcoin-cli echo hello"

## are we online?
ping -qc1 1.1.1.1 2>/dev/null >&2 || myexit 1 offline

### ############# DO THE 25 ###################
###
### do the chain of 25-in-mempool transactions
###
### ###########################################
dothetf() {
isoldb || myexit 1 "isoldb in dothetf"

: > $lpr
for i in $(seq ${1:-25})
do
  test -s "$lpr" && {
  until
    dolisto
    ! cmp $l $lpr
  do
    usleep 21
  done
  }
  cd $wd
  fee=$(awklist-all.sh -d $otra < $l \
    | mktx.sh | crt.sh | srt.sh | fee.sh)
  awklist-all.sh -f $fee -d $otra < $l  \
    | mktx.sh | crt.sh | srt.sh | safecat.sh $shf
  sertl <$shf
  grep -q . $sfl || break
  cp $l $lpr
done
myexit 1 dothetf
}

cleanupr() {
  intx=$1

  : > $fdir/sffgt
  cd $wd
  bch.sh gettransaction $intx | jq -r .details[].address \
    | safecat.sh $fdir/sffgt
  cd $myp
  rm -rf $fdir/sff-s3/0*
  rm -rf $fdir/_toomany
  d=$fdir/sffrest
  cd $d
  mymv $fdir/sff-s2 $fdir/sff-s3 $d
  cat $fdir/sffgt | xargs rm -rf
}

##############################
### from blocknotify-signet.sh
isoldb || {
  rmdir $fdir/sffnewblock
  d=$fdir/sffrest
  mkdir -p $d
  mymv $fdir/sff $d

  doinito

  tx=$(cat $l | head -1 | grep .) || myexit 1 "isoldb newblock tx"
  txid=${tx%% *}

  cleanupr $txid

  cd $wd
  feenit=$(awklist-all.sh -d $otra < $l \
    | mktx.sh | crt.sh | srt.sh | fee.sh)
  awklist-all.sh -f $feenit -d $otra < $l  \
    | mktx.sh | crt.sh | srt.sh | safecat.sh $shf
  sertl <$shf
  read -r txid < $sfl

  dolisto

  lpr=$fdir/l123p
  rm -rf $lpr

  cd $wd
  fee=$(awklist-all.sh -d $otra < $l \
    | mktx.sh | crt.sh | srt.sh | fee.sh)
  echo $fee > $fdir/fee
  awklist-all.sh -f $fee -d $otra < $l  \
    | mktx.sh | crt.sh | srt.sh | safecat.sh $shf
  sertl <$shf
  read -r last < $sfl

  dothetf

  cd $myp
  catapultleftovers

  test -d $fdir/sffnewblock && myexit 1 "new block again"

  d=$fdir/sffrest
  mymv $fdir/sff $d
  cd $d
  ls -1 "$d" \
    | head -n 1800 | xargs mv -t $fdir/sff 2>/dev/null
  myexit 1 "isoldb end"
}
##############################
##############################
##############################

skipround() {
  # quickfix
  dolisto

  tx=$(cat $l | head -1 | grep .) || myexit 1 "skipround newblock tx"
  txid=${tx%% *}

  cleanupr $txid

  cd $wd
  mylist | grep " 0 true$" | awklist-all.sh -f 500 | mktx.sh | crt.sh | srt.sh | sertl
  cd $myp
}

dolisto

# was: clean-sff.sh
tx=$(cat $l | head -1 | grep .) || myexit 1 "EARLY newblock tx"
txid=${tx%% *}
test "$txid" = "" && myexit 1 "empty TXID"
echo "$txid" | grep -E '[0-9a-f]{64}' || myexit 1 "strange TXID"

gengmep
test -s "$gmef" || dothetf
# sets vsize weight time height descendantcount descendantsize
# ancestorcount ancestorsize wtxid base modified ancestor descendant
. $gmep
test "$ancestorcount" = "25" || {
  if
    test "$ancestorcount" = "1"
  then
    dothetf $((25-$ancestorcount))
  else
    test "$ancestorcount" -lt "24" && skipround
    myexit 1 skipround
  fi
}
test "$descendantcount" = "1" || myexit 1 "descendantcount"
test "$vsize" -lt 98299 || myexit 1 "early TOO BIG vsize $vsize"
depends=$(jq -r .depends[0] < $gmef)
dce=$(echo $depends | ce.sh)

value=$(getamount)
outsum=$(($value-${base:-0}))

mkdir -p $fdir/sff-s2
mkdir -p $fdir/sff-s3

d=$fdir/sffrest
mkdir -p $d
randomone=$(($RANDOM%2))
ls -1 $fdir/sff/ | grep -q . || { ####
d=$fdir/sffrest

test -d $fdir/_toomany || {
cd $d
  ls -1 2>/dev/null | head -n $((((98000-$vsize-51)/52)+$randomone)) \
    | xargs mv -t $fdir/sff/ 2>/dev/null
}
} # ls above

find $fdir/sff/ $fdir/sff-s2/ $fdir/sff-s3/ -mindepth 1 -type f 2>/dev/null \
  | sort -u \
  | xargs cat \
  | safecat.sh $nusff

newouts=$(wc -l < $nusff)
echo $newouts | safecat.sh $fdir/newouts
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

########################################################
########################################################
########################################################

dvs=$vsize

cd $wd
dotx | safecat.sh $fdir/us

cd $wd
cat $fdir/us | txcat.sh | srt.sh | safecat.sh $shf
cd $sdi
vsizenew=$(fee.sh < $shf | grep .) || myexit 1 "missing vsizenew"
echo vsize $vsize vsizenew $vsizenew >&2
test $vsizenew -le 100000 || { mkdir $fdir/_toomany; myexit 1 "TOO BIG"; }
#test $vsizenew -le 100000 || myexit 1 "TOO BIG"

#########################################################

dvs=$(( $vsizenew+$base ))
cd $wd
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
    feer=$(feer $sats $vsizenew)
  }
dvs=$sats

  new=1000
  test $max -gt 25991051601 && new=40000
  test $max -gt 35991051601 && new=80000
  test $max -gt 85991051601 && new=100000
  test $max -gt 105991051601 && new=300000
  test $max -gt 115991051601 && new=500000
  test $max -gt 125991051601 && new=1100000
  new=$(($new+$newouts))
  test "$new" -gt 330 || myexit 1 "at the end: new $new is too low"
  rest=$(($max-$sats-$new*$newouts))
  hhasum=$(($outsum + $base - ${max:-0} + $rest))
  echo ${hhasum:-0} | grep -q -- - && myexit 1 "hhasum ${hhasum:-0}"

# needs $new and $nusff
newh=$(hex $new - 16 | ce.sh | grep .) || myexit 1 "newh $newh"
cat $nusff | sed "s/^/$newh/" | safecat.sh $of

cd $wd
dotx | txcat.sh | srt.sh | safecat.sh $shf
cd $sdi
sertl <$shf
ret=$?
echo ofeer $ofeer feer4 $feer sats $sats >&2
echo max $max fee-rate $feer base $base vsize $vsizenew >&2

myexit $ret "finn"
