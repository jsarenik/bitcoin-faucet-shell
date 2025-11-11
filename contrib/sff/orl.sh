#!/bin/sh

msg=${1:"test"}

msg=$(printf "$msg" | xxd -p)
lend=$((${#msg}/2))
len=$(printf "%02x" $lend)
leno=$(printf "%02x" $(($lend+2)))
test $lend -ge 76 && { len="4c$len"; leno=$(printf "%02x" $((0x$leno+1))); }
echo 0000000000000000 $leno 6a$len $msg
