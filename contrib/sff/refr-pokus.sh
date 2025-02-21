cd ~/.bitcoin/signet/wallets

net=$(hnet.sh)
dt=/home/nsm/.bitcoin/signet/wallets/pokus202412-dt.txt
od=pokus202412
old=$(readlink $od)

while
  new=restp$$
  test -d $new
do
  echo Existing dir $new
done

tmpo=/dev/shm/wallets-$net/$old
tmpd=/dev/shm/wallets-$net/$new
mkdir $tmpd
ln -s $tmpd .
bch.sh createwallet $new false true
cd $new
A=$(sed 's/"timestamp".*$/"timestamp":"now",/' $dt | jq -rc .descriptors)
bch.sh importdescriptors $A
. /dev/shm/UpdateTip-signet
bch.sh rescanblockchain $(($height-10))
cd ..

cd $old
cdf=/tmp/compare-diff-$net-$$
until
  list.sh > $cdf
  (cd ../$new; list.sh | cmp $cdf )
do
  echo waiting for wallet synchronization
  busybox sleep 10
  i=$((${i:-0}+1))
  test $i -gt 10 && { cd ../$new; ulw.sh; exit 1; }
done
cd ..

echo $new
ln -nsf $new pokus202412
cd $old
ulw.sh && cd .. && rm -rf $old && rm -rf $tmpo
