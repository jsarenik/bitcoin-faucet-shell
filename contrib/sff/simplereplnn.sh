#echo $$ >&2
lock=/tmp/locksff
mkdir $lock || exit 1

myexit() {
  ret=${1:-$?}
  cat $sfl
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
  {
  cat
  echo 0
  } | bch.sh -rpcclienttimeout=9 -stdin sendrawtransaction
}

#set -o errexit
set -o pipefail
tx=$(list.sh | sort -rn -k 3 | grep -m1 " 0 true$") || {
  list.sh | grep "[1-9] true$" | safecat.sh /tmp/mylist
  cat /tmp/mylist | awklist-all.sh -fr \
    | mktx.sh | crt.sh | srt.sh | sertl
  myexit 0
}
tx=$(list.sh | sort -rn -k 3 | grep -m1 " 0 true$")
txid=${tx%% *}
hf=/tmp/replnhex
bff=/tmp/replbasefee
gmef=/tmp/sff-gme
asf=/tmp/sff-ancestorsize
sfl=/tmp/sfflast
errf=/tmp/sff-err
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
new=$(($max/100/$newouts))
test "$new" -gt 330 || myexit
rest=$(($max-$new*$newouts))

# needs $new and /tmp/nosff
of=/tmp/sff-outs
newh=$(hex $new - 16 | ce.sh)
cat /tmp/nosff | sed "s/^/$newh/" | safecat.sh $of

# basefee
read -r bf < $bff
read -r as < $asf
weight=$(cat $hf | drt.sh | jq -r .weight)
cfr=$(((1000*$bf/$weight+999)/1000))
#echo $cfr
#rmdir $lock 2>/dev/null
#exit

. /dev/shm/UpdateTip-signet
hold=$height

cat $hf | nd-untilout.sh | safecat.sh $hf-uo

dotx() {
. /dev/shm/UpdateTip-signet
test "$hold" = "$height" || myexit
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

hha=$(hex $(($outsum + $bf - $max + $rest - 31 - $cfr*$vsize)) - 16 | ce.sh)
dotx | txcat.sh | srt.sh | safecat.sh /tmp/sffhex

add=$vsize
dvs=$(( 2*$add ))
hha=$(hex $(($outsum + $bf - $max + $rest - 31 - $dvs)) - 16 | ce.sh)

#########################################################
#########################################################
echo stage 2 >&2

dotx | txcat.sh | v3.sh | srt.sh | safecat.sh /tmp/sffhex
vsizenew=$(cat /tmp/sffhex | fee.sh)
add=0
test $vsize -lt $vsizenew \
  && add=2
test "$vsizenew" -lt 10000 || myexit
: > $errf
sertl 2>$errf >$sfl </tmp/sffhex
ret=$?

#########################################################

echo stage 3 >&2

cat $errf >&2
#mmf=$(grep "^mempool min fee not met," $errf | grep .)
#mmf=$(echo $mmf | cut -d'<' -f2 | grep .)
#test "$mmf" = "" || echo mempool min fee $mmf >&2
fee=$(grep -o "old feerate .*" $errf | tr -cd '[0-9]' | sed 's/^0\+//')
echo fee-rate $fee vsize $vsizenew >&2
#echo vsize $vsizenew >&2
gmm=$(gmm-gen.sh)
#mmf=$(gmi.sh | grep minfee | cut -d: -f2 | tr -d " ,." | sed 's/^0\+//')
#dvs=$(( $as+$mmf+$bf+($vsizenew*${fee:-20569}+999)/1000))
#dvs=$(( $max+$mmf+($vsizenew*${fee:-20569}+999)/1000))

#dvs=$(( $vsizenew))
dvs=0
#test "$mmf" = "" || dvs=$(( $mmf+$vsizenew))
test "$fee" -gt 1 && dvs=$(( ($vsizenew*${fee:-29568}+999)/1000))
##dvs=$(( $as-$bf+$mmf+$vsizenew))
##dvs=$(( $bf + $vsizenew ))
hha=$(hex $(($outsum + (${1:-$add}) - $max + $rest - $dvs)) - 16 | ce.sh)
#hha=$(hex $(($outsum + $bf - $max + $rest - 31 - $dvs)) - 16 | ce.sh)
echo "$outsum + $bf = $(($outsum+$bf))" >&2
dotx | txcat.sh | v3.sh | srt.sh | safecat.sh /tmp/sffhex
#: > $errf
#sertl 2>$errf >$sfl </tmp/sffhex
#cat $errf >&2
#ret=$?

############
test -s $errf && {
echo stage 4 >&2
fee=$(grep ^insufficient $errf | cut -d= -f2 | tr -cd '[0-9]' | sed 's/^0\+//')
#nfee=$((fee+1000))
echo fee-rate $fee vsize $vsizenew ad $as >&2
#dvs=$(( $add+($vsizenew*${fee:-29568}+999)/1000))
dvs=$(( ($vsizenew*${fee:-29568}+999)/1000))
hha=$(hex $(($outsum - $vsizenew + (${1:-$add}) + $bf - $max + $rest - $dvs)) - 16 | ce.sh)
#hha=$(hex $(($outsum - 20 - $max + $rest - $dvs)) - 16 | ce.sh)
dotx | txcat.sh | v3.sh | srt.sh | safecat.sh /tmp/sffhex
sertl 2>$errf >$sfl </tmp/sffhex
ret=$?
}
#ls -t | grep '^[0-9]\+$' | xargs rm -v >&2

myexit $ret
