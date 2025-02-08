#!/bin/sh
grep -v '^#' $1 | tr -d ' [A-Z]:\n' | grep .
