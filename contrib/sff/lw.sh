#!/bin/sh

OLDPWD=$PWD
a=$(readlink $PWD)
test "$a" = "" || {
  echo "$a" | grep -q '^/' && : || cd "../$a"
}
bch.sh $OLDPWD loadwallet ${PWD##*/}
