#!/bin/sh
ph=$(bch.sh getblockchaininfo | jq -r .pruneheight)
bch.sh rescanblockchain $ph
