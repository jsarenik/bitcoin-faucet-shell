#!/bin/sh
a="/$0"; a="${a%/*}"; a="${a:-.}"; a="${a##/}/"; BINDIR=$(cd "$a" || true; pwd)
hashv="$(sha256sum $0 | cut -b 59-64)"
test "$1" = "-V" && { echo "v$hashv"; exit; }

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
skiprf=$fdir/skiprlast
sfr=$fdir/sffrest
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
ad=bitcoindevs.xyz
mcm=25 # will be 64 when miner runs clustered mempool

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
  : > $sfl
  {
  cat
  echo 0.21
  } | bch.sh -rpcclienttimeout=9 -stdin sendrawtransaction \
      2>$errf >$sfl
}

myexit() {
  ret=${1:-$?}
  test -s $sfl && {
    cat $sfl
  }
  test "$ret" = "0" && {
    mymv $fdir/sff $fdir/sff-s3
  } || {
    mymv $fdir/sff $sfr
  }
  test "$newouts" = "" && read -r newouts < $fdir/newouts
  echo newouts $newouts >&2

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
  #mylist | grep -v " 0 [tf][a-z]\+$" | grep " true$" | sort -rn -k3
  mylist | grep " true$" | sort -rn -k3
}

doinito() {
  : > $l
  doinit | safecat.sh $l
}

dolist() {
  mylist | grep " 0 true$" | sort -rn -k3
}

dolisto() {
  : > $l
  dolist | safecat.sh $l
}

mysrt() {
  bch.sh -stdin signrawtransactionwithwallet \
    | grep '"hex"' \
    | cut -d: -f2- \
    | tr -d ' ,"'
}

catapultleftovers() {
  tmpc=$(mktemp /dev/shm/catapultleft-$net-XXXXXX) || exit 1
  list=$tmpc
  lh=${list}-hex

  : > $list
  mylist | grep " 0 false$" | safecat.sh $list
  test -s $list || return
  num=$(wc -l < $list)

  cat $list | awk '($3<=0.01){print $1, $2, $3}' \
    | awklist-allfee.sh \
    | mktx.sh | crt.sh | mysrt | sert.sh
  rm -rf ${tmpc}* > /dev/null
}

isnewb() {
  mylist | grep ' [^0]+ true$'
}

isoldb() {
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
  gme.sh $txid | safecat.sh $gmef
  tr -d '{} \t",.' < $gmef \
    | sed '/^depends/,$d' \
    | sed '/^fees/d; $d' | tr : = \
    | sed 's/=0\+/=/' \
    | safecat.sh $gmep
}

getamount() {
  grt.sh $depends | drt.sh | jq -r '.vout[0].value' | tr -d .
}

thousands() {
  echo $1 | busybox sed -r -e ':L' -e 's=([0-9]+)([0-9]{3})=\1,\2=g' -e 't L'
}

dotx() {
  hha=$(hex ${hhasum:-0} - 16 | ce.sh)
  echo 0200000001${dce}0000000000fdffffff

  printouts $((12+${newouts:-0})) # increment outputs when enabling more

  echo $hha 22 5120aac35fe91f20d48816b3c83011d117efa35acd2414d36c1e02b0f29fc3106d90
  orl.sh "alt.signetfaucet.com"
  #orl.sh "alt.signetfaucet.com | $newouts payouts | This is a test network. Coins have no value. | v$hashv | Bitcoin since 2009"
  orl.sh "$newouts payouts"
  orl.sh "of $(thousands $new) sats"
  orl.sh "This is a test network. Coins have no value. | v$hashv"
  orl.sh "Just don't sh*tcoin"
  orl.sh "How many?"
  orl.sh "There's only one"
  orl.sh "Bitcoin since 2009"
  echo f000000000000000 04 51024e73 # LN Anchor
  orl.sh "Play. Here."
  echo f000000000000000 04 51024e73 # LN Anchor

  cat $of
  hex $height - 8 | ce.sh
}

feer() {
  # Fee-rate $abs_sats_fee $divisor_vsize
  mysats=$1
  mydiv=$2
  fr=$(( (100*$mysats+$mydiv-1)/$mydiv ))
  echo $fr
}

sats() {
  # Absolute_sats_fee $feer $divisor_vsize
  myfeer=$1
  mydiv=$2
  out=$(( (($myfeer*$mydiv)+99)/100 ))
  echo $out
}

##########################################################################

# Early checks

## Is bitcoind talking RPC to us (from the wallet dir)?
cd $myp
bch.sh echo hello | grep -q . || myexit 1 "early bitcoin-cli echo hello"
cd $wd

## are we online?
ping -qc1 1.1.1.1 2>/dev/null >&2 || myexit 1 offline

### ############# DO THE $mcm ###################
###
### do the chain of $mcm-in-mempool transactions
###
### ###########################################
dothetf() {
#isoldb || myexit 1 "isoldb in dothetf"

feenit=$(awklist-all.sh -d $otra -m "$ad   " < $l \
  | mktx.sh | crt.sh | mysrt | fee.sh)
echo $feenit > $fdir/feenit
awklist-all.sh -f $feenit -d $otra -m "$ad   " < $l \
  | mktx.sh | crt.sh | mysrt | safecat.sh $shf
sertl <$shf

  test "$1" -gt "1" && {

lpr=$fdir/l123p
rm -rf $lpr
: > $lpr
dolisto
for i in $(seq -w 02 ${1:-$mcm})
do
  test -s "$lpr" && {
  until
    dolisto
    ! cmp $l $lpr
  do
    :
  done
  }
  fee=$(awklist-all.sh -d $otra -m "$ad $i" < $l \
    | mktx.sh | crt.sh | mysrt | fee.sh)
  echo $fee > $fdir/fee
  awklist-all.sh -f $fee -d $otra -m "$ad $i" < $l \
    | mktx.sh | crt.sh | mysrt | safecat.sh $shf
  sertl <$shf
  grep -q . $sfl || break
  cp $l $lpr
done
  }
}

cleanupr() {
  intx=$1

  : > $fdir/sffgt
  bch.sh gettransaction $intx | jq -r '.details[].address' \
    | safecat.sh $fdir/sffgt
  rm -rf $fdir/sff-s3/0*
  mymv $fdir/sff-s2 $fdir/sff-s3 $sfr
  cat $fdir/sffgt | (cd $sfr; xargs rm -rf)
  : > $nusff
}

##############################
### from blocknotify-signet.sh
isoldb || {
  rmdir $fdir/sffnewblock
  mkdir -p $sfr
  mymv $fdir/sff $sfr

  doinito

  tx=$(cat $l | head -1 | grep .) || myexit 1 "isoldb newblock tx"
  txid=${tx%% *}

  cleanupr $txid

  dothetf $mcm

  catapultleftovers

  test -d $fdir/sffnewblock && myexit 1 "new block again"

  mymv $fdir/sff $sfr
  find "$sfr" -type f 2>/dev/null \
    | head -n 2100 | xargs mv -t $fdir/sff 2>/dev/null
}
##############################
##############################
##############################

myminir() {
  echo Replacing the same >&2
  : > $errf
  minirepl.sh 2>$errf >$sfl
}

skipround() {
  # quickfix
  dolisto

  tx=$(cat $l | head -1 | grep .) || myexit 1 "skipround newblock tx"
  txid=${tx%% *}

  myminir
}

dolisto

# was: clean-sff.sh
tx=$(cat $l | head -1 | grep .) || myexit 1 "EARLY newblock tx"
txid=${tx%% *}
test "$txid" = "" && myexit 1 "empty TXID"
echo "$txid" | grep -E '[0-9a-f]{64}' || myexit 1 "strange TXID"

gengmep
test -s "$gmef" || myexit 1 "gmef missing"

# sets vsize weight time height descendantcount descendantsize
# ancestorcount ancestorsize wtxid base modified ancestor descendant
. $gmep
depends=$(jq -r '.depends[0]' < $gmef)
dce=$(echo $depends | ce.sh)
test "$ancestorcount" = "$mcm" || {
  skipround
  dothetf $(($mcm-$ancestorcount))
}
test "$descendantcount" = "1" || myexit 1 "descendantcount"

value=$(getamount)
outsum=$(($value))

mkdir -p $fdir/sff-s2
mkdir -p $fdir/sff-s3
mkdir -p $sfr

ls -1 $fdir/sff/ | grep -q . || { ####
  find $sfr -type f 2>/dev/null | head -n $((((98000-$vsize-51)/52))) \
    | xargs mv -t $fdir/sff/ 2>/dev/null
} # ls above

find $fdir/sff/ -mindepth 1 -type f 2>/dev/null \
  | xargs cat \
  | safeadd.sh $nusff

newouts=$(wc -l < $nusff)
test "$newouts" = "0" && myexit 1 "newouts zero"
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

dotx | txcat.sh | mysrt | safecat.sh $shf
vsizenew=$(vsize.sh < $shf | grep .) || myexit 1 "missing vsizenew"
echo vsize $vsize vsizenew $vsizenew >&2
test $vsizenew -le 100000 || { mkdir -p $fdir/_toomanyr; myexit 1 "TOO BIG"; }

#########################################################

dvs=$(( $vsizenew+$base ))

############
# stage 4
############

sats=$(( $base + ($vsizenew+9)/10 ))
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
  test $max -gt 105991051601 && new=$((100000000/$newouts))
  test $max -gt 115991051601 && new=$((200000000/$newouts))
  test $max -gt 125991051601 && new=$((1100000000/$newouts))
  test "$new" -gt 330 || myexit 1 "at the end: new $new is too low"
  rest=$(($sats+$new*$newouts+480))
  hhasum=$(($outsum - $rest))
  echo ${hhasum:-0} | grep -q -- - && myexit 1 "hhasum ${hhasum:-0}"

# needs $new and $nusff
newh=$(hex $new - 16 | ce.sh | grep .) || myexit 1 "newh $newh"
cat $nusff | sed "s/^/$newh/" | safecat.sh $of

dotx | txcat.sh | mysrt | safecat.sh $shf
sertl <$shf
ret=$?
echo ret $ret

test "$ret" != "0" && { myminir; ret=$?; }

myexit $ret "finn"
