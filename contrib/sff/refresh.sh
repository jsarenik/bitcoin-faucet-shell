net=$(hnet.sh)

add=$RANDOM
add=my$add

################################################
# reads ~/.testkeys with following variables
# privkey=WIFprivatekey
# wpkhcs=checksum
# trcs=checksum
# combocs=checksum
# nestedcs=checksum
# npkhcs=checksum
# wshcs=checksum
#
# privkeyo=WIFotherLegacyPrivKey
# pkhcs=checksum
# onestedcs=checksum
# owshcs=checksum
################################################
. $HOME/.testkeys
bch.sh -named createwallet wallet_name=new$add blank=true
cd new$add
bch.sh importdescriptors '''[{ "desc": "wpkh('$privkey')#'$wpkhcs'", "timestamp": "now" }]'''
bch.sh importdescriptors '[{ "desc": "tr('$privkey')#'$trcs'", "timestamp": "now" }]'
bch.sh importdescriptors '[{ "desc": "pkh('$privkey')#'$npkhcs'", "timestamp": "now" }]'
bch.sh importdescriptors '[{ "desc": "sh(wpkh('$privkey'))#'$nestedcs'", "timestamp": "now" }]'
bch.sh importdescriptors '[{ "desc": "wsh(pkh('$privkey'))#'$wshcs'", "timestamp": "now" }]'
bch.sh importdescriptors '[{ "desc": "pkh('$privkeyo')#'$pkhcs'", "timestamp": "now" }]'
bch.sh importdescriptors '[{ "desc": "sh(wpkh('$privkeyo'))#'$onestedcs'", "timestamp": "now" }]'
bch.sh importdescriptors '[{ "desc": "wsh(pkh('$privkeyo'))#'$owshcs'", "timestamp": "now" }]'
#bch.sh importdescriptors '[{ "desc": "combo('$privkey')#'$combocs'", "timestamp": "now" }]'
cd ..
old=$(readlink newnew)
cd $old
rm -rf /tmp/compare-diff-$net
cdf=/tmp/compare-diff-$net-$$
until
  list.sh | safecat.sh $cdf
  (cd ../new$add; list.sh | cmp $cdf )
do
  echo waiting for wallet synchronization
  busybox sleep 10
done
cd ..

ln -nsf new$add newnew
du -hs $old
du -hs newnew/

cd $old
#fee=$(list.sh | awklist-all.sh -f 111 | mktx.sh | crt.sh | srt.sh | fee.sh 1)
#list.sh | awklist-all.sh -f $fee | mktx.sh | crt.sh | srt.sh | sert.sh
ulw.sh && cd .. && rm -rfv $old
#bch.sh unloadwallet && cd .. && rm -rf new$add
