#!/bin/sh
#echo $$ >&2
lock=/tmp/rsw
test -d $lock && exit 1
lock=/tmp/locksff
mkdir $lock || exit 1

export HOME=/home/nsm
sfs=/tmp/sff-sfs # sff-flag-slowdown
sfsn=2000
errf=/tmp/sff-err
nusff=/tmp/nosff
sfl=/tmp/sfflast
shf=/tmp/sffhex
phf=/tmp/sffphf
pkf=/tmp/sffpkf
addmyf=$HOME/.bitcoin/signet/wallets/addmy
sdi=$HOME/.bitcoin/signet
myp=$sdi/wallets
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
  {
  cat
  echo 0
  } | bch.sh -rpcclienttimeout=9 -stdin sendrawtransaction \
      2>$errf >$sfl
}

myexit() {
  ret=${1:-$?}
  d=/tmp/sffrest
  #test -s $sfl && cat $sfl
  test "$ret" = "0" && {
    mymv /tmp/sff /tmp/sff-s2
  } || {
    mymv /tmp/sff /tmp/sffrest
  }
  mymv /tmp/sff-s2 /tmp/sff-s3
  ls -t1 "$d" | wc -l | safecat.sh /dev/shm/sffrest.txt
  myrest=$(ls -1 /tmp/sffrest/ | wc -l)
  myst=$(ls -1 /tmp/sff-s3/ | wc -l)
  echo rest $myrest stage3 $myst >&2

  echo ${2:-"SUCCESS $ret"} >&2
  rmdir $lock 2>/dev/null
  exit $ret
}

cd $myp
bch.sh echo hello | grep -q . || myexit 1 "early bitcoin-cli echo hello"

# are we online?
ping -qc1 1.1.1.1 2>/dev/null >&2 || myexit 1 offline

##############################
### from blocknotify-signet.sh
rmdir /tmp/sffnewblock 2>/dev/null || test "$1" = "-f" && {
rm -rf $sfs
test "$1" = "-f" && shift
d=/tmp/sffrest
mkdir -p $d
mymv /tmp/sff $d

cd $myp/newnew
list.sh | grep "[1-9] true$" | sort -rn -k3 | safecat.sh /tmp/mylist
cd $myp

# was: clean-sff.sh
tx=$(cat /tmp/mylist | head -1 | grep .) || myexit 1 "EARLY newblock tx"
txid=${tx%% *}
cd $myp/newnew
  bch.sh gettransaction $txid | jq -r .details[].address \
    | sort -u | safecat.sh /tmp/sffgt
cd $myp
rm -rf /tmp/sff-s3/0*
d=/tmp/sffrest
cd $d
mymv /tmp/sff-s2 /tmp/sff-s3 $d
  cat /tmp/sffgt | xargs rm -rf

l=/tmp/mylist
lpr=/tmp/l123p
cd $myp/newnew
  fee=$(awklist-all.sh -d $otra < /tmp/mylist \
    | mktx.sh | crt.sh | srt.sh | fee.sh)
  awklist-all.sh -f $fee -d $otra < /tmp/mylist  \
    | mktx.sh | crt.sh | srt.sh | safecat.sh $shf
  sertl <$shf | grep -q . || break
for i in $(seq 25)
do
  test -s $lpr && {
  until
    cd $myp/newnew
    list.sh | grep " true$" | safecat.sh $l
    ! cmp $l $lpr
  do
    sleep 0.2
  done
  }
  . /dev/shm/UpdateTip-signet
  test "$hold" = "$height" || break
  fee=$(awklist-all.sh -d $otra < /tmp/mylist \
    | mktx.sh | crt.sh | srt.sh | fee.sh)
  awklist-all.sh -f $fee -d $otra < /tmp/mylist  \
    | mktx.sh | crt.sh | srt.sh | safecat.sh $shf
  sertl <$shf | grep -q .
# || break
  cp $l $lpr
done

cd $myp
signetcatapultleftovers.sh

test -d /tmp/sffnewblock && myexit 1 "new block again"

d=/tmp/sffrest
mymv /tmp/sff $d
cd $d
  ls -t1 "$d" \
    | head -n 1800 | xargs mv -t /tmp/sff
}
##############################
##############################
##############################

l=/tmp/mylist
cd $myp/newnew

cd $myp/newnew || myexit 1 "early cd newnew"
list.sh | grep " 0 true$" | sort -rn -k3 | safecat.sh /tmp/mylist
cd $myp

printouts() {
  test ${1:-1} -lt 252 \
    && { hex ${1:-1} - 2 | grep .; } \
    || { printf "fd"; hex ${1:-1} - 4 | ce.sh; }
}

#set -o errexit
#set -o pipefail
#set +o pipefail
tx=$(head -1 /tmp/mylist | grep .) || myexit 1 "main loop tx issue"
tx=${1:-$tx}
txid=${tx%% *}

test "$txid" = "" && myexit 1 "empty TXID"

gmef=/tmp/sff-gme
gmep=/tmp/sff-gme.sh
gtof=/tmp/sff-gtot

hf=/tmp/replnhex
grt.sh $txid | safecat.sh $hf
test -s $hf || myexit 1 "grt hf"
sertl < $hf
grep '^03' $hf && myexit 1 "V3 no more"

: > $gmef
: > $gmep
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
test -s $gmef || myexit 1 "missing $gmef"
jq -r .spentby[] < $gmef | grep -q . && myexit 1 "FOREIGN CHILD SPEND"

tr -d '{} \t",.' < $gmef \
  | sed '/^depends/,$d' \
  | sed '/^fees/d; $d' | tr : = \
  | sed 's/=0\+/=/' \
  | safecat.sh $gmep
# sets vsize weight time height descendantcount descendantsize
# ancestorcount ancestorsize wtxid base modified ancestor descendant
. $gmep
test "$vsize" -lt 98299 || myexit 1 "early TOO BIG vsize $vsize"

outsum=$(($value-$base))
mkdir -p /tmp/sff-s2
mkdir -p /tmp/sff-s3

d=/tmp/sffrest
mkdir -p $d
randomone=$(($RANDOM%2))
ls -1 /tmp/sff/ | grep -q . || {
d=/tmp/sffrest
cd $d
  ls -t1 2>/dev/null | head -n $((((98000-$vsize-51)/52)+$randomone)) \
    | xargs mv -t /tmp/sff/
}

ls -1 /tmp/sff | grep -q . || myexit 1 "no new outputs"
find /tmp/sff/ /tmp/sff-s2/ /tmp/sff-s3/ -mindepth 1 -type f 2>/dev/null \
  | xargs cat \
  | safecat.sh $nusff

newouts=$(wc -l < $nusff)
test "$newouts" -ne "0" || myexit 1 "no new outputs"
test $newouts -gt $sfsn && mkdir -p $sfs
newoutso=$newouts
newoutsadd=$((210-$newouts))
newoutsadd=0
test $newoutsadd -lt 0 && newoutsadd=0
echo NEWOUTSADD $newoutsadd >&2
newouts=$(($newouts+$newoutsadd))
max=$(cat /tmp/mylist | sum.sh | tr -d . | sed 's/^0\+//' | grep '^[0-9]\+$') \
  || myexit 1 "unknown max $max"
test $max -gt 330 || myexit 1 "low max $max"
new=$(($max/102/$newouts))
test "$new" -gt 330 || myexit 1 "new $new is too low"
rest=$(($max-$new*$newouts))

# needs $new and $nusff
of=/tmp/sff-outs
newh=$(hex $new - 16 | ce.sh | grep .) || myexit 1 "newh $newh"
{ cat $nusff; test "$newoutsadd" -gt 0 && head -n $newoutsadd $addmyf; } \
  | sed "s/^/$newh/" | safecat.sh $of


dotx() {
  . /dev/shm/UpdateTip-signet
  test "$hold" = "$height" || myexit 1 "$hold $height new block in the meantime"

  hhasum=$(($outsum + $base - ${max:-0} + $rest))
  echo $hhasum | grep -q -- - && myexit 1 "hhasum $hhasum"
  hha=$(hex $hhasum - 16 | ce.sh)
  echo 0200000001${dce}0000000000fdffffff
  printouts $((2+$newouts))
  echo $hha 22 5120aac35fe91f20d48816b3c83011d117efa35acd2414d36c1e02b0f29fc3106d90
  finta=$(printf " | %4d" $newoutso | xxd -p)
  echo 00000000000000001d6a1b616c742e7369676e65746661756365742e636f6d$finta
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
echo stage 1 >&2

dvs=$vsize

cd $myp/newnew
dotx | safecat.sh /tmp/us

cd $myp/newnew
cat /tmp/us | txcat.sh | srt.sh | safecat.sh $shf
cd $sdi
vsizenew=$(fee.sh < $shf | grep .) || myexit 1 "missing vsizenew"
echo vsize $vsize vsizenew $vsizenew >&2
test $vsizenew -le 100000 || myexit 1 "TOO BIG"

#########################################################
echo stage 3 >&2

dvs=$(( $vsizenew+$base ))
test "$vsizenew" = "$vsize" && myexit 1 "no change"
cd $myp/newnew
dotx | txcat.sh | srt.sh | safecat.sh $shf
cd $sdi

############
# stage 4
############

echo stage 4 >&2
sats=$(( $base + $vsizenew ))
  ofeer=$(feer $base $vsize | grep .) || myexit 1 "ofeer $ofeer vsize $vsize"
  feer=$(feer $sats $vsizenew | grep .) || myexit 1 "feer $feer"
  test $feer -lt $ofeer && {
    sats=$(sats $(($ofeer+1)) $vsizenew)
  }
dvs=$sats

dividend=$(($max/1000/1000/100/7))
echo DIVIDEND is $dividend >&2
  new=$(( ($max/($dividend+24)/2016) - ($newouts%12) ))
  test "$new" -gt 330 || myexit 1 "at the end: new $new is too low"
  rest=$(($max-$dvs-$new*$newouts))

# needs $new and $nusff
newh=$(hex $new - 16 | ce.sh | grep .) || myexit 1 "newh $newh"
{ cat $nusff; test "$newoutsadd" -gt 0 && head -n $newoutsadd $addmyf; } \
  | sed "s/^/$newh/" | safecat.sh $of

cd $myp/newnew
dotx | txcat.sh | srt.sh | safecat.sh $shf
cd $sdi
sertl <$shf
ret=$?
echo feer4 $feer sats $sats >&2
echo ofeer $ofeer feer $feer >&2
echo max $max fee-rate $feer base $base vsize $vsizenew >&2

myexit $ret "finn"
