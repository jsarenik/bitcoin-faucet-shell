#!/bin/sh

test "$1" = "-o" && {
  drt.sh | jq -r .vsize
  exit
}

drt.sh | jq -r '((.vsize + 9)/10 | trunc)'
#grt.sh  074a3e683004c7a5418eafecb1f3a9244de03f551f799bc1b67a3e6b068b80fa | drt.sh | jq -r '((.vsize + 9)/10 | trunc)'
