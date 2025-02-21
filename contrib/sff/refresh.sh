net=$(hnet.sh)

. $HOME/.testkeys

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
bch.sh importdescriptors '''[{ "desc": "wpkh('$privkey')#'$wpkhcs'", "timestamp": "now" }]'''
bch.sh importdescriptors '[{ "desc": "tr('$privkey')#'$trcs'", "timestamp": "now" }]'
bch.sh importdescriptors '[{ "desc": "pkh('$privkey')#'$npkhcs'", "timestamp": "now" }]'
bch.sh importdescriptors '[{ "desc": "sh(wpkh('$privkey'))#'$nestedcs'", "timestamp": "now" }]'
bch.sh importdescriptors '[{ "desc": "wsh(pkh('$privkey'))#'$wshcs'", "timestamp": "now" }]'
bch.sh importdescriptors '[{ "desc": "pkh('$privkeyo')#'$pkhcs'", "timestamp": "now" }]'
bch.sh importdescriptors '[{ "desc": "sh(wpkh('$privkeyo'))#'$onestedcs'", "timestamp": "now" }]'
bch.sh importdescriptors '[{ "desc": "wsh(pkh('$privkeyo'))#'$owshcs'", "timestamp": "now" }]'
#bch.sh importdescriptors '[{ "desc": "combo('$privkey')#'$combocs'", "timestamp": "now" }]'
. /dev/shm/UpdateTip-signet
bch.sh rescanblockchain $(($height-10))
cd ..
old=$(readlink newnew)
tmpo=/dev/shm/wallets-$net/$old
cd $old
list.sh | grep " 0 true" \
  || list.sh | awklist-all.sh -f 50000 | mktx.sh | crt.sh | srt.sh | sert.sh
rm -rf /tmp/compare-diff-$net-*
cdf=/tmp/compare-diff-$net-$$
until
  list.sh | safecat.sh $cdf
  (cd ../$neww; list.sh | cmp $cdf )
do
  echo waiting for wallet synchronization
  busybox sleep 10
  i=$((${i:-0}+1))
  test $i -gt 10 && { cd ../$neww; ulw.sh; exit 1; }
done
cd ..

ln -nsf $neww newnew
du -hs $old
du -hs newnew/

cd $old
#fee=$(list.sh | awklist-all.sh -f 111 | mktx.sh | crt.sh | srt.sh | fee.sh 1)
#list.sh | awklist-all.sh -f $fee | mktx.sh | crt.sh | srt.sh | sert.sh
ulw.sh && cd .. && rm -rfv $old
#bch.sh unloadwallet && cd .. && rm -rf $neww

#echo old was $tmpo
rm -rf $tmpo
