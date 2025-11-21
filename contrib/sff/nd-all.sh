#!/bin/sh

index=0
tx=00
next=00
nextd=00
prev=0

echonl() {
  echo $next
}
echon() {
  echo -n $next
}
echom() {
  echo -n " $next"
}
mydd() {
  next=$(busybox dd bs=2 count=${1:-1} 2>/dev/null)
  ##many=$((2*${1:-1}))
  #index=$((2*${2:-0}))
  ##index=$((2*${2:-0}+2*${prev:-0}))
  ##next=${tx:$index:$many}
  ##prev=$((${prev:-0}+${1:-1}))
  #tx=${tx:$many}
}
scs() {
  test "$next" = "" && echo "scs ERROR" >&2 && exit 1
  test $((0x$next)) -lt 253 && nextd=$next && return
  test $((0x$next)) -eq 253 && {
    echom; mydd 2; nextd=$(echo $next | ce.sh)
  }
  test $((0x$next)) -eq 254 && {
    echom; mydd 4; nextd=$(echo $next | ce.sh)
  }
  test $((0x$next)) -eq 255 && {
    echom; mydd 8; nextd=$(echo $next | ce.sh)
  }
}

#if
#  test "$1" = ""
#then
#  read -r tx
#else
#  tx=$1
#fi

#end=\${tx: -8}
#end=$(echo $BH | cut -b61-64)

mydd 4 # version
printf "VERSION: "; echo $next

flag=0
mydd # flag check
test "$next" = "00" && {
  printf "FLAG: 0001 #W-0001" && mydd && mydd; echo
  flag=1
}

printf "INPUTS: " # scs without mydd is intentional ^^^
scs; echon
#; test "$(($nextd))" -gt 1 && echo " #0..$((0x$nextd-1))" || echo
echo " #I-0..$((0x$nextd-1))"
inputs=$((0x$nextd))

for i in $(seq 0 $(($inputs-1)))
do
  mydd 32
  echom
  mydd 4
  echom
  mydd; scs; echom
  test "$next" = "00" || { mydd $((0x$nextd)); echom; }
  mydd 4
  echom
  echo " #I-$i"
  #echo
done

# outputs
printf "OUTPUTS: "
#mydd; scs; echon; echo " #0..$((0x$nextd-1))"
mydd; scs; echon
#; test "$(($nextd))" -gt 1 && echo " #0..$((0x$nextd-1))" || echo
echo " #O-0..$((0x$nextd-1))"

#for i in $(seq $((0x$nextd)))
for i in $(seq 0 $((0x$nextd-1)))
do
  mydd 8
  echom
  mydd; scs; echom
  test "$next" = "00" || { mydd $((0x$nextd)); echom; }
  echo " #O-$i"
  #echo
done

test "$flag" = "1" && {
printf "WITNESS: "
echo " #W-0..$((0x$inputs-1))"

#for i in $(seq $inputs)
for i in $(seq 0 $(($inputs-1)))
do
  #echo "# witness for input $i"
  mydd; scs; echom
  for y in $(seq $((0x$nextd)))
  do
    mydd; scs; echom
    test "$next" = "00" || { mydd $((0x$nextd)); echom; }
  done
  echo " #W-$i"
  #echo
done
}

printf "LOCKTIME: "; mydd 4; echonl
# echo 00000000
# echo $end
