#!/bin/sh

# This is run kind of hourly by sff-loop.sh

# optional configuration file (see signetfaucet.conf)
test "$1" = "-c" && { conf=$2; shift 2; }
test "$conf" = "" || { test -r $conf && . $conf; }
export fdir=${fdir:-/tmp}
export sdi=${sdi:-$HOME/.bitcoin/signet}

# lock file, used also by refreshsignetwallets.sh
lock=$fdir/locksff
mkdir $lock || exit 1

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
cd ..

cd $jw
ulw.sh
rm /dev/shm/wallets-signet/$jw/wallet.dat
cd ..
bch.sh createwallet $jw true true
cd $jw
bch.sh importdescriptors '[{"desc": "addr(tb1qft5p2uhsdcdc3l2ua4ap5qqfg4pjaqlp250x7us7a8qqhrxrxfsqaqh7jw)#gtc05zpf","timestamp": "now"}]'
cd ..

cd ddeployment
ulw.sh
# there's a link in place already:
#  ln -nsf /dev/shm/ddeployment.dat wallet.dat
rm /dev/shm/ddeployment.dat
cd ..
bch.sh createwallet ddeployment false true
cd ddeployment
sh importdesc.sh
cd ..

rmdir $lock
