#!/bin/sh
tmp=$(mktemp /tmp/tmp25new-XXXXXX)
trap "rm $tmp" EXIT INT QUIT
list.sh | grep " true$" | safecat.sh $tmp
sum=$(sums.sh < $tmp)
addr=tb1pfp672fs37lpjx08gvva8nwh2t048vr8rdvl5jvytv4de9sgp6yrq60ywpv

gmm=$(gmm.sh)
ad=bitcoindevs.xyz

gentx() {
  fee=${1:-0}
  acn=${2:-"  "}
  add=$addr
  mkrawh.sh < $tmp
  echo 02
  hex $(($sum-(($fee*$gmm+999)/1000))) - 16 | ce.sh
  genofa.sh $add
  orl.sh "$ad $acn"
  echo 00000000
}

sendit() {
  gentx $(gentx | txcat.sh | srt.sh | fee.sh -o) "$1" "$addr" | txcat.sh | srt.sh | safecat.sh $tmp
  sert.sh < $tmp
}

txid=`list.sh | awk '{print $1}'`
ac=$(gme.sh $txid | jq -r .ancestorcount | grep .)
test "$ac" = "" || ac=$(($ac+1))

sendit $ac | safecat.sh $tmp

grep -E '^[0-9a-f]{64}$' $tmp && exit 0
grep too-large-cluster $tmp && exit 1
