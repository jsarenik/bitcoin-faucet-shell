#!/bin/sh

bch.sh getmempoolentry $1
# | tr -d ' ",[]' | sed '1d;$d'
