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
    | sed "s/^/mv /;s|$| $to|" | sh -s
}

mkpack() {
  printf '['
  {
    cat $shf
    cat $phf
  } | sed 's/^/"/;s/$/"/' | paste -d, -s | tr -d '\n'
  printf ']'
}

submitp() {
  bch.sh -stdin submitpackage < $pkf
}

mklnas() {
  mytx=$1
  . /dev/shm/UpdateTip-signet
  {
    echo 03000000
    echo 01
    echo $mytx | ce.sh
    echo 02000000 00 fdffffff
    echo 01
    echo 0000000000000000 11 6a0f696e20666565732077652072757374
    hex $height - 8 | ce.sh
  } | tr -d ' \n' | grep .
}

sertl() {
  : > $errf
  cd $myp
  mtxid=$(drt.sh < $shf | jq -r .txid)
#  echo inside sertl $mtxid >&2
#  mklnas $mtxid | safecat.sh $phf
#  mkpack | safecat.sh $pkf
#  submitp < $pkf \
#      2>$errf >$sfl
#  ! grep -q '"error"' $errf
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
d=/tmp/sffrest
mymv /tmp/sff-s2 /tmp/sff-s3 $d
#rm -rf $d/tb1pfees9rn5nz
  cat /tmp/sffgt | (cd /tmp/sffrest; xargs rm -rf)

l=/tmp/mylist
lpr=/tmp/l123p
cd $myp/newnew
  fee=$(awklist-all.sh -d $otra < /tmp/mylist \
    | mktx.sh | crt.sh | srt.sh | fee.sh)
  awklist-all.sh -f $fee -fm -d $otra < /tmp/mylist  \
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
  awklist-all.sh -f $fee -fm -d $otra < /tmp/mylist  \
    | mktx.sh | crt.sh | srt.sh | safecat.sh $shf
  sertl <$shf | grep -q .
# || break
  cp $l $lpr
done

list=/tmp/pokus2list
: > $list
cd $myp/pokus202412
  list.sh | grep " true$" | safecat.sh $list
test -s $list && {
  num=$(wc -l < $list)
  cd $myp/pokus202412
  cat $list | awklist-all.sh \
    | mktx.sh | crt.sh | srt.sh | safecat.sh $shf
  fee=$(fee.sh < $shf)
  cd $myp/pokus202412
  cat $list | awklist-all.sh -f $fee -fm \
    | mktx.sh | crt.sh | srt.sh | safecat.sh $shf
  sertl <$shf
  cat $errf >&2
}

cd $myp
signetcatapultleftovers.sh

l=/tmp/mylist
lpr=/tmp/l123p

for i in $(seq 25)
do
  test -s $lpr && {
  until
    cd $myp/newnew || myexit 1 "early cd newnew $(($i+1))"
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
  awklist-all.sh -f $fee -fm -d $otra < /tmp/mylist  \
    | mktx.sh | crt.sh | srt.sh | safecat.sh $shf
  sertl <$shf | grep -q . || break
  cp $l $lpr
done

test -d /tmp/sffnewblock && myexit 1 "new block again"

d=/tmp/sffrest
#rm -rf $d/tb1pfees9rn5nz
mymv /tmp/sff $d
  ls -t1 "$d" \
    | head -n 2016 | sed 's/^/mv /;s|$| /tmp/sff/|' | (cd $d; sh -s)
}
##############################
##############################
##############################

cd $myp/newnew || myexit 1 "early cd newnew"
list.sh | grep " true$" | sort -rn -k3 | safecat.sh /tmp/mylist
#list.sh | sort -rn -k3 | head -1 | safecat.sh /tmp/mylist
cd $myp

l=/tmp/mylist
cd $myp/newnew

cd $myp/newnew || myexit 1 "early cd newnew"
#list.sh | grep " 0 true$" | sort -rn -k3 | head -1 | safecat.sh /tmp/mylist
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
bff=/tmp/replbasefee
gmef=/tmp/sff-gme
asf=/tmp/sff-ancestorsize

hf=/tmp/replnhex
grt.sh $txid | safecat.sh $hf
test -s $hf || myexit 1 "grt hf"
sert.sh < $hf
grep '^03' $hf && myexit 1 "V3 no more"

: > $gmef
gme.sh $txid | safecat.sh $gmef
#jq -r .spentby[] < $gmef | grep -q . && myexit 1 "V3 CHILD SPEND"
af=""
test -s $gmef && {
  $(jq -r '.fees.descendant <= 0.01' < $gmef) || myexit 1 "V3 CHILD FEE HIGH"
  af=$(jq -r '.fees.descendant' < $gmef)
  af=$(echo $af | cut -d: -f2 | tr -dc '[0-9]' | tr -d . | sed 's/^0\+//')
}

cat $gmef | grep -w base \
  | cut -d: -f2 | tr -dc '[0-9]' | tr -d . | sed 's/^0\+//' \
  | safecat.sh $bff
cat $gmef | grep -w ancestorsize \
  | cut -d: -f2 | tr -dc '[0-9]' | tr -d . | sed 's/^0\+//' \
  | safecat.sh $asf
vsize=$(cat $hf | fee.sh | grep .) || myexit 1 "invalid vsize"
test "$vsize" -lt 99999 || myexit 1 "early TOO BIG vsize $vsize"
outsum=$(cat $hf | nd-outs.sh | cut -b-16 | ce.sh | fold -w 16 \
	| while read l; do echo $((0x$l)); done | paste -d+ -s | bc)
mkdir -p /tmp/sff-s2
mkdir -p /tmp/sff-s3

d=/tmp/sffrest
mkdir -p $d
randomone=$(($RANDOM%2))
ls -1 /tmp/sff/ | grep -q . || {
d=/tmp/sffrest
#rm -rf $d/tb1pfees9rn5nz
  ls -t1 "$d" 2>/dev/null | head -n $((((100000-$vsize)/52)-$randomone)) \
    | sed 's/^/mv /;s|$| /tmp/sff/|' | (cd $d; sh -s)
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
max=$(cat /tmp/mylist | sum.sh | tr -d . | sed 's/^0\+//' | grep '^[0-9]\+$') \
  || myexit 1 "unknown max $max"
test $max -gt 330 || myexit 1 "low max $max"
test $max -gt 52330902625 && max=52330902625
new=$(($max/180/$newouts))
test "$new" -gt 330 || myexit 1 "new $new is too low"
rest=$(($max-$new*$newouts))

# needs $new and /tmp/nosff
of=/tmp/sff-outs
newh=$(hex $new - 16 | ce.sh | grep .) || myexit 1 "newh $newh"
{ cat /tmp/nosff; test "$newoutsadd" -gt 0 && head -n $newoutsadd $addmyf; } \
  | sed "s/^/$newh/" | safecat.sh $of

# basefee
read -r bf < $bff
read -r as < $asf

cat $hf | nd-untilout.sh | safecat.sh $hf-uo

dotx() {
  . /dev/shm/UpdateTip-signet
  test "$hold" = "$height" || myexit 1 "$hold $height new block in the meantime"
  hhasum=$(($outsum + $bf - 240 - $max + $rest - $dvs))
  echo $hhasum | grep -q -- - && myexit 1 "hhasum $hhasum"
  hha=$(hex $hhasum - 16 | ce.sh)
  cat $hf-uo
  printouts $((3+$newouts))
  echo $hha 22 5120aac35fe91f20d48816b3c83011d117efa35acd2414d36c1e02b0f29fc3106d90
  finta=$(printf " | %4d" $newoutso | xxd -p)
  echo 00000000000000001d6a1b616c742e7369676e65746661756365742e636f6d$finta
  echo f0000000000000000451024e73
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

cat /tmp/us | txcat.sh | srt.sh | safecat.sh $shf
cd $sdi
vsizenew=$(cat $shf | fee.sh | grep .) || myexit 1 "missing vsizenew"
echo vsize $vsize vsizenew $vsizenew >&2
test "$vsizenew" -lt 100000 || myexit 1 "TOO BIG"

#cd $myp/newnew
#dotx | txcat.sh | srt.sh | safecat.sh $shf
#cd $sdi

#########################################################
echo stage 3 >&2

#cat $errf >&2

dvs=$(( $vsizenew+$bf))
test "$vsizenew" = "$vsize" && vsizenew=$(($vsizenew+1))
cd $myp/newnew
dotx | txcat.sh | srt.sh | safecat.sh $shf
cd $sdi

############
# stage 4
############

echo stage 4 >&2
af=${af:-$bf}
sats=$(( $af+$vsizenew ))
  ofeer=$(feer $af $vsize | grep .) || myexit 1 "ofeer $ofeer af $af vsize $vsize"
  feer=$(feer $sats $vsizenew | grep .) || myexit 1 "feer $feer"
  test $feer -lt $ofeer && {
    sats=$(sats $(($ofeer+1)) $vsizenew)
  }
dvs=$sats
cd $myp/newnew
dotx | txcat.sh | srt.sh | safecat.sh $shf
cd $sdi
sertl <$shf
ret=$?
echo feer4 $feer sats $sats >&2
echo ofeer $ofeer feer $feer >&2
echo max $max fee-rate $feer bf $bf vsize $vsizenew >&2

myexit $ret "finn"
