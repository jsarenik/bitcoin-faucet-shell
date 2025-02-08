#!/bin/ash

index=0
tx=00
next=00

echon() {
  echo -n $next
}
echom() {
  echo -n " $next"
}
mydd() {
  many=$((2*${1:-1}))
  index=$((2*${2:-0}))
  next=${tx:$index:$many}
  tx=${tx:$many}
}
scs() {
  test $((0x$next)) -lt 253 || {
    res=""; mydd; res=$next; mydd; next=$next$res
  }
}

if
  test "$1" = ""
then
  read -r tx
else
  tx=$1
fi

end=${tx: -8}

mydd 4 # version
#echo -n $next
mydd # flag check
test "$next" = "00" && mydd && mydd #|| echo
#test "$next" = "00" && mydd && echo " 00$next" && mydd || echo
#echo

scs
#echo $next

for i in $(seq $((0x$next)))
do
  mydd 32
  #echon
  mydd 4
  #echom
  #echo
  mydd
  scs
  #echom
  test "$next" = "00" || { mydd $((0x$next)); : echom; }
  mydd 4
  #echom
  #echo
done

# outputs
mydd
scs
#echo $next

for i in $(seq $((0x$next)))
do
  mydd 8
  echon
  mydd; scs; # echom
  test "$next" = "00" || { mydd $((0x$next)); echom; }
  echo
done

#echo $end
