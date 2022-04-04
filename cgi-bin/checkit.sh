#!/bin/sh

lightning-cli decode $1 | jq .description_hash
