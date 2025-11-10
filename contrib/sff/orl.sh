#!/bin/sh

msg=${1:"test"}

msg=$(printf "$msg" | xxd -p)
lend=$((${#msg}/2))
len=$(printf "%02x" $lend)
leno=$(printf "%02x" $(($lend+2)))
echo 0000000000000000 $leno 6a$len $msg
