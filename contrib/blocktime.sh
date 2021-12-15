address=$1
address=${address:-tb1pnly8e0xxln6en66qh2uu0kj3sg0ejjgmdcnf2ke6uc5lujh9gkwq8ndv02}
echo "$address" | grep -qE '^(tb1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{39}|tb1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{59}|[mn2][a-zA-HJ-NP-Z0-9]{25,33})$' || exit 1
op=${address%${address#?}}
echo $op | grep -qE '[mn2t]' || exit 1
test "$op" = "t" && op=${address%${address#????}}
#echo $op
address=${address##${op}}
echo $op/$address
