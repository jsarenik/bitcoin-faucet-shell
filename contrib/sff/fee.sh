#!/bin/sh

drt.sh | jq -r '((.vsize + 9)/10 | trunc)'
