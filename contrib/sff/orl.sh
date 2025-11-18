#!/bin/sh

msg=${1:"test"}
msgf=/tmp/orl-msg

if
  test "$1" = ""
then
  cat > $msgf
else
  printf "$msg" > $msgf
fi

lend=$(stat -c %s $msgf)

len=$(printf "%02x" $lend)
leno=$(printf "%02x" $(($lend+2)))

test $lend -ge 76 && { len="4c$len"; leno=$(printf "%02x" $((0x$leno+1))); }
test $lend -ge 253 && {
  len="4d$(printf "%04x" $lend | ce.sh)"
  leno="fd$(printf "%04x" $(($lend+4)) | ce.sh)"
}
test $lend -gt $((0xffff)) && {
  len="4e$(printf "%08x" $lend | ce.sh)"
  leno="fe$(printf "%08x" $(($lend+6)) | ce.sh)"
}

echo 0000000000000000 $leno 6a$len
xxd -p < $msgf
