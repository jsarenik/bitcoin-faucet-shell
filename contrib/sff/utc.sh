#!/bin/sh

net=$(hnet.sh)
fn=$net
test "$net" = "main" && fn=bitcoin

cat /dev/shm/UpdateTip-$fn
