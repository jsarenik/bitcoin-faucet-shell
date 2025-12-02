#!/bin/sh

hash=$(sha256sum simplereplnn.sh | cut -b 59-64)
echo "v$hash"
