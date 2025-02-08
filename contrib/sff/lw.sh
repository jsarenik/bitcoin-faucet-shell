#!/bin/sh

a=$(readlink $PWD)
test "$a" = "" || cd ../$a
bch.sh loadwallet ${PWD##*/}
