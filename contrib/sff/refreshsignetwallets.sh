#!/bin/sh

# This is run @hourly by cron

lockr=/tmp/sfflock
mkdir $lockr || exit 1

lock=/tmp/rsw
mkdir $lock || exit 1
rmdir $lockr
. $HOME/.profile
mkdir -p /dev/shm/wallets-signet/lnanchor
jw=optrue
mkdir -p /dev/shm/wallets-signet/$jw

cd ~/.bitcoin/signet/wallets
ash refresh.sh

cd lnanchor
ulw.sh
rm /dev/shm/wallets-signet/lnanchor/wallet.dat
cd ..
bch.sh createwallet lnanchor true true
cd lnanchor
bch.sh importdescriptors '[{"desc": "addr(tb1pfees9rn5nz)#8njps4hg","timestamp": "now"}]'
. /dev/shm/UpdateTip-signet
bch.sh rescanblockchain $(($height-20))
cd ..

cd $jw
ulw.sh
rm /dev/shm/wallets-signet/$jw/wallet.dat
cd ..
bch.sh createwallet $jw true true
cd $jw
bch.sh importdescriptors '[{"desc": "addr(tb1qft5p2uhsdcdc3l2ua4ap5qqfg4pjaqlp250x7us7a8qqhrxrxfsqaqh7jw)#gtc05zpf","timestamp": "now"}]'
. /dev/shm/UpdateTip-signet
bch.sh rescanblockchain $(($height-20))
cd ..

rmdir $lock
