#!/bin/sh

read -r sl < /tmp/sfflast
list.sh | grep -q ${sl:-NonExisTenT}  && rm -rf /tmp/sff-s2/*
rm -rf /tmp/sff-s3/*
