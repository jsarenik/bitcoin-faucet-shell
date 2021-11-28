#!/bin/sh

URL=https://signet.bublina.eu.org/claim
ADDR=tb1p83p7yperh6yw6dtvgqvxr7m3crkyxczeezdcp7x07d6aa5vtv7pq8w4j90

torsocks -i /usr/bin/wget \
  "$URL/?address=$ADDR&amount=0.001"
