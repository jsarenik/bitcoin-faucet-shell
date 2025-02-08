#!/bin/sh

bch.sh -stdin signrawtransactionwithwallet \
  | grep '"hex"' \
  | cut -d: -f2- \
  | tr -d ' ,"'
