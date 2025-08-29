net=$(hnet.sh)
export LC_ALL=C

myim() {
  gdi=$(bch.sh getdescriptorinfo "$1")
  cs=$(echo $gdi | jq -r .checksum)
  rode=$(echo $gdi | jq -r .descriptor)
  bch.sh importdescriptors '''[{"desc":"'$1'#'$cs'","timestamp":"now"}]''' \
    2>/dev/null | grep -q . && {
    echo $rode
    bch.sh deriveaddresses $rode 2>/dev/null
  }
}

. $HOME/.testkeys
dt=/home/nsm/.bitcoin/signet/wallets/pokus202412-dt.txt

while
  add=$RANDOM
  add=my$add
  neww=new$add
  test -d $neww
do
  echo Existing dir $neww
done

tmpd=/dev/shm/wallets-$net/$neww
mkdir $tmpd
ln -s $tmpd .
bch.sh -named createwallet wallet_name=$neww blank=true
cd $neww

myim "pk($privkey)"
myim "sh(pk($privkey))"
myim "wsh(pk($privkey))"
myim "pkh($privkey)"
myim "sh(pkh($privkey))"
myim "wsh(pkh($privkey))"
myim "sh(wsh(pkh($privkey)))"
myim "wpkh($privkey)"
myim "sh(wpkh($privkey))"
myim "tr($privkey)"
myim "wsh(sortedmulti(2,$privkey,$privkeyo))"

myim "pkh($privkeyo)"
myim "sh(wpkh($privkeyo))"
myim "wsh(pkh($privkeyo))"
myim "tr($privkeyo)"

myim "tr($lmabi)"
myim "pk($uncom)"
myim "sh(pk($uncom))"
myim "combo($uncom)"

A=$(sed 's/"timestamp".*$/"timestamp":"now",/' $dt | jq -rc .descriptors)
bch.sh importdescriptors $A
. /dev/shm/UpdateTip-signet
bch.sh rescanblockchain $(($height-60))
sleep 1

cd ..
old=$(readlink newnew)
tmpo=/dev/shm/wallets-$net/$old
test -d $old && {
cd $old
list.sh | grep " 0 true" \
  || list.sh | awklist-all.sh -f 50000 | mktx.sh | crt.sh | srt.sh | sert.sh
cd ..
}

ln -nsf $neww newnew
du -hs $old/
du -hs newnew/

cd $old || { rm -rf $tmpo; exit 1; }
#fee=$(list.sh | awklist-all.sh -f 111 | mktx.sh | crt.sh | srt.sh | fee.sh 1)
#list.sh | awklist-all.sh -f $fee | mktx.sh | crt.sh | srt.sh | sert.sh
ulw.sh && cd .. && rm -rfv $old
#bch.sh unloadwallet && cd .. && rm -rf $neww

#echo old was $tmpo
rm -rf $tmpo
