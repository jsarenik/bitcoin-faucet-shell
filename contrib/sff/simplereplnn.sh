#!/bin/sh
a="/$0"; a="${a%/*}"; a="${a:-.}"; a="${a##/}/"; BINDIR=$(cd "$a" || true; pwd)
. $BINDIR/sffshared.sh.inc
. $BINDIR/sffunk.sh.inc

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

##############################
### from blocknotify-signet.sh
isoldb || {
  rmdir $fdir/sffnewblock
  d=$fdir/sffrest
  mkdir -p $d
  mymv $fdir/sff $d

  doinito

  tx=$(cat $l | head -1 | grep .) || myexit 1 "EARLY newblock tx"
  txid=${tx%% *}
  cd $wd
  : > $fdir/sffgt
  bch.sh gettransaction $txid | jq -r .details[].address \
    | sort -u | safecat.sh $fdir/sffgt
  cd $myp
  rm -rf $fdir/sff-s3/0*
  rm -rf $fdir/_toomany
  d=$fdir/sffrest
  cd $d
  mymv $fdir/sff-s2 $fdir/sff-s3 $d
  cat $fdir/sffgt | xargs rm -rf

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
    | head -n 1800 | xargs mv -t $fdir/sff
  myexit 1 "isoldb end"
}
##############################
##############################
##############################

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
test "$ancestorcount" = "25" || dothetf $((25-$ancestorcount))
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
    | xargs mv -t $fdir/sff/
}
} # ls above

find $fdir/sff/ $fdir/sff-s2/ $fdir/sff-s3/ -mindepth 1 -type f 2>/dev/null \
  | sort -u \
  | xargs cat \
  | safecat.sh $nusff

newouts=$(wc -l < $nusff)
echo $newouts | safecat.sh $fdir/newouts
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

cd $wd
dotx | txcat.sh | srt.sh | safecat.sh $shf
cd $sdi
sertl <$shf
ret=$?
echo ofeer $ofeer feer4 $feer sats $sats >&2
echo max $max fee-rate $feer base $base vsize $vsizenew >&2

myexit $ret "finn"
