#!/bin/sh

# This is run @hourly by cron

lock=/tmp/sfflock
test -d $lock && exit 1

lock=/tmp/rsw
mkdir $lock || exit 1
. $HOME/.profile
mkdir -p /dev/shm/wallets-signet/lnanchor

cd ~/.bitcoin/signet/wallets
ash refresh.sh
ash refr-pokus.sh

cd lnanchor
#lts.sh | awk '{print $1}' | sort -u | rpf.sh
#wv.sh
#fullrpf20.sh
ulw.sh
rm /dev/shm/wallets-signet/lnanchor/wallet.dat
cd ..
bch.sh createwallet lnanchor true true
cd lnanchor
bch.sh importdescriptors '[{"desc": "addr(tb1pfees9rn5nz)#8njps4hg","timestamp": "now"}]'
. /dev/shm/UpdateTip-signet
bch.sh rescanblockchain $(($height-20))
cd ..

rmdir $lock
