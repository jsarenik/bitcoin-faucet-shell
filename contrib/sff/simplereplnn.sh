#!/bin/sh
#echo $$ >&2
lock=/tmp/rsw
test -d $lock && exit 1
lock=/tmp/locksff
mkdir $lock || exit 1

export HOME=/home/nsm
errf=/tmp/sff-err
sfl=/tmp/sfflast
shf=/tmp/sffhex
addmyf=$HOME/.bitcoin/signet/wallets/addmy
sdi=$HOME/.bitcoin/signet
myp=$sdi/wallets

sertl() {
  : > $errf
  cd $myp
  {
  cat
  echo 0
  } | bch.sh -rpcclienttimeout=9 -stdin sendrawtransaction \
      2>$errf >$sfl
}

myexit() {
  ret=${1:-$?}
  d=/tmp/sffrest
  test -s $sfl && cat $sfl
  test "$ret" = "0" && {
    echo SUCCESS >&2
    mv /tmp/sff/* /tmp/sff-s2/ 2>/dev/null
  } || {
    mv /tmp/sff/* /tmp/sffrest/ 2>/dev/null
  }
  mv /tmp/sff-s2/* /tmp/sff-s3/ 2>/dev/null
  ls -t1 "$d" | wc -l | safecat.sh /dev/shm/sffrest.txt
  myrest=$(ls -1 /tmp/sffrest/ | wc -l)
  myst=$(ls -1 /tmp/sff-s3/ | wc -l)
  echo rest $myrest stage3 $myst >&2

  echo ${2:-"myexit"} >&2
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
test "$1" = "-f" && shift
d=/tmp/sffrest
mkdir -p $d
mv /tmp/sff/* $d/ 2>/dev/null

cd $myp/newnew
list.sh | grep "[1-9] true$" | sort -rn -k3 | safecat.sh /tmp/mylist
cd $myp

# was: clean-sff.sh
tx=$(cat /tmp/mylist | head -1 | grep .) || myexit 1 "newblock tx"
txid=${tx%% *}
cd $myp/newnew
  bch.sh gettransaction $txid | jq -r .details[].address \
    | sort -u | safecat.sh /tmp/sffgt
cd $myp
d=/tmp/sffrest
mv /tmp/sff-s2/* $d/ 2>/dev/null
mv /tmp/sff-s3/* $d/ 2>/dev/null
  cat /tmp/sffgt | (cd /tmp/sffrest; xargs rm -rf)

cd $myp/newnew
cat /tmp/mylist | awklist-all.sh \
  | mktx.sh | crt.sh | srt.sh | safecat.sh $shf
fee=$(fee.sh < $shf)
cat /tmp/mylist | awklist-all.sh -f $fee \
  | mktx.sh | crt.sh | srt.sh | safecat.sh $shf
sertl <$shf
cat $errf >&2
cd $myp
signetcatapultleftovers.sh

list=/tmp/pokus2list
: > $list
cd $myp/pokus202412
  list.sh | grep "[1-9] true$" | safecat.sh $list
test -s $list && {
  num=$(wc -l < $list)
cd $myp/pokus202412
cat $list | awklist.sh \
  | mktx.sh | crt.sh | srt.sh | safecat.sh $shf
fee=$(fee.sh < $shf)
cd $myp/pokus202412
cat $list | awklist.sh -f $fee -a 99999 \
  | mktx.sh | crt.sh | srt.sh | safecat.sh $shf
sertl <$shf
cat $errf >&2
}

test -d /tmp/sffnewblock && myexit 1 "new block again"
d=/tmp/sffrest
mv /tmp/sff/* $d/ 2>/dev/null
ls -1 /tmp/sff-s3 | grep -q . || {
  ls -t1 $d 2>/dev/null \
    | head -n 210 | while read a; do mv "$d/$a" /tmp/sff/; done
}
}
##############################

cd $myp/newnew || myexit 1 "early cd newnew"
list.sh | grep " 0 true$" | sort -rn -k3 | head -1 | safecat.sh /tmp/mylist
cd $myp

printouts() {
  test ${1:-1} -lt 252 \
    && hex ${1:-1} - 2 \
    || { printf "fd"; hex ${1:-1} - 4 | ce.sh; }
}

#set -o errexit
#set -o pipefail
#set +o pipefail
tx=$(cat /tmp/mylist | head -1 | grep .) || myexit 1 "main loop tx issue"
txid=${tx%% *}
test "$txid" = "" && myexit 1 "empty TXID"
hf=/tmp/replnhex
bff=/tmp/replbasefee
gmef=/tmp/sff-gme
asf=/tmp/sff-ancestorsize
grt.sh $txid | safecat.sh $hf
test -s $hf || myexit 1 "grt hf"
gme.sh $txid | safecat.sh $gmef
cat $gmef | grep -w base \
  | cut -d: -f2 | tr -dc '[0-9]' | tr -d . | sed 's/^0\+//' \
  | safecat.sh $bff
cat $gmef | grep -w ancestorsize \
  | cut -d: -f2 | tr -dc '[0-9]' | tr -d . | sed 's/^0\+//' \
  | safecat.sh $asf
vsize=$(cat $hf | vsize.sh | grep .) || myexit 1 "invalid vsize"
test "$vsize" -lt 9999 || myexit 1 "early TOO BIG vsize $vsize"
outsum=$(cat $hf | nd-outs.sh | cut -b-16 | ce.sh | fold -w 16 \
	| while read l; do echo $((0x$l)); done | paste -d+ -s | bc)
mkdir -p /tmp/sff-s2
mkdir -p /tmp/sff-s3

d=/tmp/sffrest
mkdir -p $d
randomone=$(($RANDOM%2))
ls -1 /tmp/sff/ | grep -q . || {
  ls -t1 "$d" 2>/dev/null | head -n $(((10000-$vsize)/50+$randomone)) \
    | while read a; do mv "$d/$a" /tmp/sff; done
}

ls -1 /tmp/sff >&2
find /tmp/sff/ /tmp/sff-s2/ /tmp/sff-s3/ -mindepth 1 2>/dev/null | xargs cat \
  | sort -u | shuf | safecat.sh /tmp/nosff

newouts=$(wc -l < /tmp/nosff)
test "$newouts" -ne "0" || myexit 1 "no new outputs"
newoutso=$newouts
newoutsadd=$((210-$newouts))
test $newoutsadd -lt 0 && newoutsadd=0
echo NEWOUTSADD $newoutsadd >&2
newouts=$(($newouts+$newoutsadd))
max=$(cat /tmp/mylist | sum.sh | tr -d . | sed 's/^0\+//' | grep '^[0-9]\+$') || max=90000000
#max=$(($max-3210000000))
#max=$(($max-$max/52))
new=$(($max/52/$newouts))
test "$new" -gt 330 || myexit 1 "new $new is too low"
rest=$(($max-$new*$newouts))

# needs $new and /tmp/nosff
of=/tmp/sff-outs
newh=$(hex $new - 16 | ce.sh)
{ cat /tmp/nosff; test "$newoutsadd" -gt 0 && head -n $newoutsadd $addmyf; } \
  | sed "s/^/$newh/" | safecat.sh $of

# basefee
read -r bf < $bff
read -r as < $asf
weight=$(cat $hf | drt.sh | jq -r .weight)

. /dev/shm/UpdateTip-signet
hold=$height

cat $hf | nd-untilout.sh | safecat.sh $hf-uo

myadd=$1

dotx() {
. /dev/shm/UpdateTip-signet
test "$hold" = "$height" || myexit 1 "$hold $height new block in the meantime"
add=${myadd:-0}
#echo add $add >&2
#hha=$(hex $(($outsum + $vsizenew + $add - $max + $rest - $dvs)) - 16 | ce.sh)
hha=$(hex $(($outsum + $bf - ($add) - $max + $rest - $dvs)) - 16 | ce.sh)
cat $hf-uo
printouts $((2+$newouts))
echo $hha 22 5120aac35fe91f20d48816b3c83011d117efa35acd2414d36c1e02b0f29fc3106d90
# 31 is OP_RETURN alt.signetfaucet.com
#echo 0000000000000000166a14616c742e7369676e65746661756365742e636f6d
finta=$(printf " | %3d" $newoutso | xxd -p)
echo 00000000000000001c6a1a616c742e7369676e65746661756365742e636f6d$finta
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
  mydiv=$2
  fr=$((1000*$mysats/$mydiv))
  echo $fr
}

sats() {
  # Absolute_sats_fee $feer $divisor_vsize
  myfeer=$1
  mydiv=$2
  out=$(((($myfeer)+999)*$mydiv/1000))
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
add=${myadd:-0}

#hha=$(hex $(($outsum + (${1:-$add}) - $max + $rest - $dvs)) - 16 | ce.sh)
cd $myp/newnew
dotx | txcat.sh | v3.sh | srt.sh | safecat.sh $shf
cd $sdi
vsizenew=$(cat $shf | fee.sh | grep .) || myexit 1 "missing vsizenew"
echo vsize $vsize vsizenew $vsizenew add $add >&2
test "$vsizenew" -lt 10000 || myexit 1 "TOO BIG"

#sertl <$shf
ofeer=$((((4000*$bf)+3)/$weight))
feer=$(($ofeer+1000))
echo ofeer $ofeer feer $feer >&2
test $feer -ge $(($max-1000)) && myexit 1 "some non-sense here"
echo max $max fee-rate $feer bf $bf vsize $vsizenew >&2
dvs=$(( $bf+(($vsizenew-$vsize)*$feer+999)/1000))
cd $myp/newnew
dotx | txcat.sh | v3.sh | srt.sh | safecat.sh $shf
cd $sdi
#sertl <$shf
#ret=$?
#test -s $errf || myexit 1

#########################################################
echo stage 3 >&2

#cat $errf >&2

dvs=$(( $vsizenew+$bf))
test "$vsizenew" = "$vsize" && vsize=0
cd $myp/newnew
dotx | txcat.sh | v3.sh | srt.sh | safecat.sh $shf
cd $sdi
#tma.sh <$shf
sertl <$shf
ret=$?
cat $errf | grep . || myexit $ret

grep "^insufficient fee, rejecting replacement" $errf || myexit 1 "no fee-rate"

############
# stage 4
############

test -s $errf && {
echo stage 4 >&2
fee=$(grep "^insufficient fee, rejecting replacement" $errf \
  | cut -d'<' -f2 | tr -dc '[0-9]' | tr -d . | sed 's/^0\+//')
echo fee4 $fee >&2
#dvs=$(($bf+$(sats $feer $vsizenew)))
dvs=$(( $bf+(($vsizenew-$vsize)*$feer+999)/1000))
cd $myp/newnew
dotx | txcat.sh | v3.sh | srt.sh | safecat.sh $shf
cd $sdi
#tma.sh <$shf
sertl <$shf
ret=$?
test "$ret" = "0" || {

grep "^insufficient fee, rejecting replacement" $errf
fee=$(grep "^insufficient fee, rejecting replacement" $errf \
  | cut -d'<' -f2 | tr -dc '[0-9]' | tr -d . | sed 's/^0\+//')
echo fee5 $fee >&2
dvs=$(( $vsizenew+($vsizenew*$fee+999)/1000))
cd $myp/newnew
dotx | txcat.sh | v3.sh | srt.sh | safecat.sh $shf
cd $sdi
#tma.sh <$shf
sertl <$shf
ret=$?
grep "^insufficient fee, rejecting replacement" $errf
}
}

myexit $ret
