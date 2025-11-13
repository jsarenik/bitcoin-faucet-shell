#!/bin/sh

msg=${1:"test"}
msgf=/tmp/orl-msg

if
  test "$1" = ""
then
  cat > $msgf
else
  printf "$msg" | xxd -p > $msgf
fi

lend=$(stat -c %s $msgf)

len=$(printf "%02x" $lend)
leno=$(printf "%02x" $(($lend+2)))

test $lend -ge 76 && { len="4c$len"; leno=$(printf "%02x" $((0x$leno+1))); }
test $lend -ge 253 && {
  len=$(printf "%04x" $lend)
  leno=$(printf "%04x" $(($lend+3)))
  len=$(echo $len | ce.sh)
  len="4d$len"
  leno=$(printf "%04x" $((0x$leno+1)) | ce.sh)
  leno="fd$leno"
}
echo 0000000000000000 $leno 6a$len
xxd -p < $msgf
