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
  cd $wd

tmpc=$(mktemp /dev/shm/catapultleft-$net-XXXXXX) || exit 1
prev=/dev/shm/previosleftovers-$net
list=$tmpc
lh=${list}-hex

: > $list
cd $wd
mylist | grep " 0 false$" | safecat.sh $list
test -s $list && {
num=$(wc -l < $list)
cd $wd

cat $list | awk '($3<=0.01){print $1, $2, $3}' | while read txid vout amount rest; do
 echo $txid $vout $amount >&2
 echo $txid $vout $amount | awklist-allfee.sh \
  | mktx.sh | crt.sh | srt.sh | sert.sh
done
}
cp $list $prev
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
  hhasum=$(($outsum + $base - ${max:-0} + $rest))
  echo $hhasum | grep -q -- - && myexit 1 "hhasum $hhasum"
  hha=$(hex $hhasum - 16 | ce.sh)
  echo 0200000001${dce}0000000000fdffffff
  printouts $((2+$newouts))
  echo $hha 22 5120aac35fe91f20d48816b3c83011d117efa35acd2414d36c1e02b0f29fc3106d90
  msg=$(printf "alt.signetfaucet.com | %4d | " $newouts | xxd -p)
  msg="${msg}$hashe"
  lend=$((${#msg}/2))
  len=$(printf "%02x" $lend)
  leno=$(printf "%02x" $(($lend+2)))
  echo 0000000000000000 $leno 6a$len $msg
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
