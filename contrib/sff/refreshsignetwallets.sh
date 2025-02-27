#!/bin/sh
#
# This is run @hourly by cron

lock=/tmp/sfflock
test -d $lock && exit 1

lock=/tmp/rsw
mkdir $lock || exit 1
. $HOME/.profile

cd ~/.bitcoin/signet/wallets
ash refresh.sh
ash refr-pokus.sh

cd lnanchor
lts.sh | awk '{print $1}' | sort -u | rpf.sh
wv.sh
cd ..

rmdir $lock
