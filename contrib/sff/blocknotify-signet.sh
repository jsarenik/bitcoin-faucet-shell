#!/bin/sh

pgrep -f 'all-sums.sh' || rmdir /tmp/lock-lnsum-*

cd ~/.bitcoin/signet

net=$(hnet.sh)
#ut.sh $net
ut.sh signet
. /dev/shm/UpdateTip-$net

rm -rf wallets/wosh-default/*last* /tmp/faucet/signetlimit /tmp/signetfaucet
WHERE=/tmp/faucet
busybox find $WHERE/.limit -mindepth 1 -type d -delete

#gmm-gen.sh
throwspam.sh

########################### lock ###########################
L=/tmp/supertail-signet
mkdir $L 2>/dev/null || exit 1

#$HOME/bin/blocknotify.sh $1 -t

#gmm=$(gmm-gent.sh)
#nm=$(nextmin.sh | awk '{print $3}')
#test $nm -lt $gmm && echo $nm || echo $gmm | safecat.sh /tmp/gmm-signet

all-sums.sh signet >/dev/null
gen-sfb.sh >/dev/null

#while 25new.sh; do : ; done
#ash ~/bin/simplereplnn.sh
#ash nohup ~/bin/simplereplnn.sh </dev/null >/dev/null 2>&1

#signetmagic.sh
rebroadcast-all.sh

rmdir $L
true
