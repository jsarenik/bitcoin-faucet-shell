#!/bin/sh

test "$(hnet.sh)" = "signet" \
  && bch.sh getblocktemplate '{"rules": ["segwit","signet"]}' \
  || bch.sh getblocktemplate '{"rules": ["segwit"]}'
