#!/bin/sh

test "$1" = "-o" && {
  drt.sh | jq -r .vsize
  exit
}

drt.sh | jq -r '((.vsize + 9)/10 | trunc)'
