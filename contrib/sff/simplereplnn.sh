#echo $$ >&2
lock=/tmp/locksff
mkdir $lock || exit 1
errf=/tmp/sff-err
sfl=/tmp/sfflast

myexit() {
  ret=${1:-$?}
  test -s $sfl && cat $sfl
  test "$ret" = "0" && {
    echo SUCCESS >&2
    mv /tmp/sff/* /tmp/sff-s2 2>/dev/null
  }
  rmdir $lock 2>/dev/null
  exit $ret
}

cd /home/nsm/.bitcoin/signet/wallets/newnew || myexit

printouts() {
  test ${1:-1} -lt 252 \
    && hex ${1:-1} - 2 \
    || { printf "fd"; hex ${1:-1} - 4 | ce.sh; }
}

sertl() {
  : > $errf
  {
  cat
  echo 0
  } | bch.sh -rpcclienttimeout=9 -stdin sendrawtransaction \
      2>$errf >$sfl
}

#set -o errexit
set -o pipefail
tx=$(list.sh | sort -rn -k 3 | grep -m1 " 0 true$") || {
  list.sh | grep "[1-9] true$" | safecat.sh /tmp/mylist
  cat /tmp/mylist | awklist-all.sh -fr \
    | mktx.sh | crt.sh | srt.sh | sertl
  myexit 1
}
tx=$(list.sh | sort -rn -k 3 | grep -m1 " 0 true$")
txid=${tx%% *}
hf=/tmp/replnhex
shf=/tmp/sffhex
bff=/tmp/replbasefee
gmef=/tmp/sff-gme
asf=/tmp/sff-ancestorsize
grt.sh $txid | safecat.sh $hf
gme.sh $txid | safecat.sh $gmef
cat $gmef | grep -w base \
  | cut -d: -f2 | tr -dc '[0-9]' | tr -d . | sed 's/^0\+//' \
  | safecat.sh $bff
cat $gmef | grep -w ancestorsize \
  | cut -d: -f2 | tr -dc '[0-9]' | tr -d . | sed 's/^0\+//' \
  | safecat.sh $asf
vsize=$(cat $hf | vsize.sh)
outsum=$(cat $hf | nd-outs.sh | cut -b-16 | ce.sh | fold -w 16 \
	| while read l; do echo $((0x$l)); done | paste -d+ -s | bc)
mkdir -p /tmp/sff-s2
mkdir -p /tmp/sff-s3
ls /tmp/sff >&2
mv /tmp/sff-s2/* /tmp/sff-s3 2>/dev/null
find /tmp/sff/ /tmp/sff-s2/ /tmp/sff-s3/ -mindepth 1 2>/dev/null | xargs cat \
  | sort -u | shuf | safecat.sh /tmp/nosff

newouts=$(cat /tmp/nosff | wc -l)
max=$(cat /tmp/mylist | sum.sh | tr -d . | sed 's/^0\+//' | grep '^[0-9]\+$') || max=90000000
#max=$(($max-3210000000))
#max=$(($max-$max/52))
new=$(($max/52/$newouts))
test "$new" -gt 330 || myexit 1
rest=$(($max-$new*$newouts))

# needs $new and /tmp/nosff
of=/tmp/sff-outs
newh=$(hex $new - 16 | ce.sh)
cat /tmp/nosff | sed "s/^/$newh/" | safecat.sh $of

# basefee
read -r bf < $bff
read -r as < $asf
weight=$(cat $hf | drt.sh | jq -r .weight)
#cfr=$(((1000*$bf/$weight+999)/1000))
#echo $cfr
#rmdir $lock 2>/dev/null
#exit

. /dev/shm/UpdateTip-signet
hold=$height

cat $hf | nd-untilout.sh | safecat.sh $hf-uo

myadd=$1

dotx() {
. /dev/shm/UpdateTip-signet
add=${myadd:-$add}
#echo add $add >&2
test "$hold" = "$height" || myexit 1
#hha=$(hex $(($outsum + $vsizenew + $add - $max + $rest - $dvs)) - 16 | ce.sh)
hha=$(hex $(($outsum + $bf + $add - $max + $rest - $dvs)) - 16 | ce.sh)
cat $hf-uo
printouts $((2+$newouts))
echo $hha 22 5120aac35fe91f20d48816b3c83011d117efa35acd2414d36c1e02b0f29fc3106d90
# 31 is OP_RETURN alt.signetfaucet.com
echo 0000000000000000166a14616c742e7369676e65746661756365742e636f6d
cat $of
hex $height - 8 | ce.sh
}

########################################################
########################################################
########################################################
echo stage 1 >&2

dvs=$vsize
add=${myadd:-0}

#hha=$(hex $(($outsum + (${1:-$add}) - $max + $rest - $dvs)) - 16 | ce.sh)
dotx | txcat.sh | v3.sh | srt.sh | safecat.sh $shf
vsizenew=$(cat $shf | fee.sh)
test "$vsizenew" -lt 10000 || myexit 1
nw=$(cat $shf | drt.sh | jq -r .weight)
#test $vsize -lt $vsizenew \
#  && add=${myadd:-3}
echo vsize $vsize vsizenew $vsizenew add $add >&2

#sertl <$shf
ofeer=$((((4000*$bf)+3)/$weight))
feer=$(($ofeer+1000))
echo ofeer $ofeer feer $feer >&2
#myexit 1
test $feer -ge $(($max-1000)) && myexit 1
echo max $max fee-rate $feer bf $bf vsize $vsizenew >&2
#test "$feer" -ge 1000 -a "$feer" -lt 100000
dvs=$(( $bf+(($vsizenew-$vsize)*$feer+999)/1000))
#dvs=$(( ($vsize*$feer+999)/1000))
dotx | txcat.sh | v3.sh | srt.sh | safecat.sh $shf
#sertl <$shf
#ret=$?
#test -s $errf || myexit 1

#########################################################
echo stage 3 >&2

#cat $errf >&2

#dvs=$vsizenew
#dvs=$(( ($vsizenew*$feer+999)/1000 ))
#dvs=$(( ($vsizenew*$feer+999)/1000))
dvs=$(( $vsizenew+$bf))
#test "$vsizenew" = "$vsize" \
#  && dvs=$(( $vsizenew+$bf)) \
#  || dvs=$(( $vsizenew+($vsize*$ofeer+999)/1000))
#  && dvs=$(( $vsizenew+(($vsizenew-$vsize)*$ofeer+999)/1000)) \
#  || dvs=$(( $vsizenew+($vsize*$ofeer+999)/1000))
test "$vsizenew" = "$vsize" && vsize=0
#dvs=$(( $vsizenew+(($vsizenew-$vsize)*$feer+999)/1000))
#dvs=$(( $bf+(($vsizenew-$vsize)*$feer+999)/1000))
#dvs=$(( ($vsize*$feer+999)/1000))
#hha=$(hex $(($outsum + $bf - $max + $rest - 31 - $dvs)) - 16 | ce.sh)
#echo "$outsum + $bf = $(($outsum+$bf))" >&2
dotx | txcat.sh | v3.sh | srt.sh | safecat.sh $shf
sertl <$shf
ret=$?
#cat $errf >&2

grep "^insufficient fee, rejecting replacement" $errf || myexit $ret

############
# stage 4
############

test -s $errf && {
echo stage 4 >&2
fee=$(grep "^insufficient fee, rejecting replacement" $errf \
  | cut -d'<' -f2 | tr -dc '[0-9]' | tr -d . | sed 's/^0\+//')
echo fee4 $fee >&2
#dvs=$(( $vsizenew+($vsizenew*${fee:-29568}+999)/1000))
#test "$vsizenew" = "$vsize" && vsize=0
dvs=$(( $bf+(($vsizenew-$vsize)*$feer+999)/1000))
#dvs=$(( ($vsizenew*($vsizenew*$fee+999)/1000) ))
dotx | txcat.sh | v3.sh | srt.sh | safecat.sh $shf
sertl <$shf
ret=$?
test "$ret" = "0" || {

grep "^insufficient fee, rejecting replacement" $errf
#hha=$(hex $(($outsum + (${1:-$add}) + $bf - $max + $rest - $dvs)) - 16 | ce.sh)
#hha=$(hex $(($outsum - 20 - $max + $rest - $dvs)) - 16 | ce.sh)
fee=$(grep "^insufficient fee, rejecting replacement" $errf \
  | cut -d'<' -f2 | tr -dc '[0-9]' | tr -d . | sed 's/^0\+//')
echo fee5 $fee >&2
dvs=$(( $vsizenew+($vsizenew*$fee+999)/1000))
dotx | txcat.sh | v3.sh | srt.sh | safecat.sh $shf
sertl <$shf
ret=$?
grep "^insufficient fee, rejecting replacement" $errf
}
}
#ls -t | grep '^[0-9]\+$' | xargs rm -v >&2

myexit $ret
