# optional configuration file (see signetfaucet.conf)
test "$1" = "-c" && { conf=$2; shift 2; }
test "$conf" = "" || . $conf
fdir=${fdir:-/tmp}
sdi=${sdi:-$HOME/.bitcoin/signet}

# lock file, used also by refreshsignetwallets.sh
lock=$fdir/locksff
mkdir $lock || exit 1

signetfaucet.sh -n
#gmm-gen.sh is in blocknotify-signet.sh now

l=$fdir/mylist
errf=$fdir/sff-err
nusff=$fdir/nosff
sfl=$fdir/sfflast
shf=$fdir/sffhex
phf=$fdir/sffphf
pkf=$fdir/sffpkf
myp=$sdi/wallets
net=$(cd $myp; hnet.sh)
wd=$myp/newnew
dent=tb1p4tp4l6glyr2gs94neqcpr5gha7344nfyznfkc8szkreflscsdkgqsdent4
otra=tb1pfp672fs37lpjx08gvva8nwh2t048vr8rdvl5jvytv4de9sgp6yrq60ywpv
xdna=tb1qg3lau83hm9e9tdvzr5k7aqtw3uv0dwkfct4xdn
feea=tb1pfees9rn5nz
gmef=$fdir/sff-gme
gmep=$fdir/sff-gme.sh
gtof=$fdir/sff-gtot
lpr=$fdir/l123p
