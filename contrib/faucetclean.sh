#!/bin/sh
#
# crontab
# 0 * * * * /path/to/faucetclean.sh

WHERE=/tmp/faucet
test -d $WHERE || exit 1

# Delete the IP limit records
/busybox/find $WHERE/.limit -mindepth 1 -type d -mmin +1440 -delete

/busybox/find $WHERE/usaddr -mindepth 2 -type d -mmin +20160 -delete
