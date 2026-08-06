#!/bin/sh
  {
  cat
  echo 0.00010000
#      1.00000000
#        12345678
  } | bch.sh -rpcclienttimeout=9 -stdin sendrawtransaction
