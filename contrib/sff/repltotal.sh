cd $HOME/.bitcoin/signet/wallets
f=/tmp/my
  #timeout 10 ash simplereplpp-nf.sh $1 || timeout 10 ash simplereplnn.sh $1
  #timeout 10 ash simplereplnn.sh $1
  timeout 20 simplereplnn.sh $1
  rm -rf /tmp/locksff
