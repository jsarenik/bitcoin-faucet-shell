#!/bin/sh

lock=$PREFIX/tmp/${0##*/}-$(echo ${PWD} | md5sum | cut -b-8)
test "$1" = "-c" && { rm -rf $lock; exit; }
mkdir $lock >/dev/null 2>&1 || exit 1

echo Rebroadcasting all transactions from the mempool...
{ grm.sh \
  | grt.sh \
  | sert.sh
} >/dev/null 2>&1

echo Rebroadcast done
rmdir $lock
