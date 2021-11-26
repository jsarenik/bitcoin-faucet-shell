#!/busybox/sh

a="/$0"; a=${a%/*}; a=${a:-.}; a=${a#/}/; HERE=$(cd $a; pwd)
export PATH=/busybox:$PATH

test "$QUERY_STRING" = "" \
  || {
    eval $(echo "$QUERY_STRING" | grep -o '[a-zA-Z]\+=[0-9a-z\.]\+')
  }

# Use just first letter of HTTP_ACCEPT - either 'a' or 't'
#  HTTP_ACCEPT='text/html...
#  HTTP_ACCEPT='application/javascript...

#. $HERE/${HTTP_ACCEPT%${HTTP_ACCEPT#?}}${REQUEST_METHOD}${O}.sh
. $HERE/${REQUEST_METHOD}${O}.sh
