#!/bin/sh

# This is run kind of hourly by sff-loop.sh

# optional configuration file (see signetfaucet.conf)
test "$1" = "-c" && { conf=$2; shift 2; }
test "$conf" = "" || { test -r $conf && . $conf; }
export fdir=${fdir:-/tmp}
export sdi=${sdi:-$HOME/.bitcoin/signet}

balf=/dev/shm/faucet/balance.txt
test -r $balf || echo 0 > $balf

# lock file, used also by refreshsignetwallets.sh
lock=$fdir/locksff
mkdir $lock || exit 1

. $HOME/.profile
mkdir -p /dev/shm/wallets-signet/lnanchor
jw=optrue
mkdir -p /dev/shm/wallets-signet/$jw
diffs=differentlys
mkdir -p /dev/shm/wallets-signet/$diffs

cd ~/.bitcoin/signet/wallets
ash refresh.sh

cd lnanchor
ulw.sh
rm /dev/shm/wallets-signet/lnanchor/wallet.dat
cd ..
bch.sh createwallet lnanchor true true
cd lnanchor
bch.sh importdescriptors '[{"desc": "addr(tb1pfees9rn5nz)#8njps4hg","timestamp": "now"}]'
height=$(gbc.sh) && bch.sh rescanblockchain $(($height-10))
cd ..
cd ~/.bitcoin/signet/wallets

cd $jw
ulw.sh
rm /dev/shm/wallets-signet/$jw/wallet.dat
cd ..
bch.sh createwallet $jw true true
cd $jw
bch.sh importdescriptors '[{"desc": "addr(tb1qft5p2uhsdcdc3l2ua4ap5qqfg4pjaqlp250x7us7a8qqhrxrxfsqaqh7jw)#gtc05zpf","timestamp": "now"}]'
height=$(gbc.sh) && bch.sh rescanblockchain $(($height-10))
cd ..
cd ~/.bitcoin/signet/wallets

cd $diffs
wf=/dev/shm/wallets-signet/differentlys/wallet.dat
test -r $wf || touch $wf
#test -r wallet.dat || touch $wf
refreshthiswallet.sh
#ulw.sh
#rm /dev/shm/wallets-signet/$diffs/wallet.dat
####ln  -nsf /dev/shm/wallets-signet/$diffs/wallet.dat .
####cd ..
#bch.sh createwallet $diffs true true
#cd $diffs
#bch.sh importdescriptors '[{"desc": "addr(tb1qft5p2uhsdcdc3l2ua4ap5qqfg4pjaqlp250x7us7a8qqhrxrxfsqaqh7jw)#gtc05zpf","timestamp": "now"}]'
cd ..
cd ~/.bitcoin/signet/wallets

cd ddeployment
ulw.sh
# there's a link in place already:
#  ln -nsf /dev/shm/ddeployment.dat wallet.dat
rm /dev/shm/ddeployment.dat
cd ..
bch.sh createwallet ddeployment false true
cd ddeployment
sh importdesc.sh
height=$(gbc.sh) && bch.sh rescanblockchain $(($height-10))
cd ..
cd ~/.bitcoin/signet/wallets

rmdir $lock
