l=/tmp/ddl
t=/tmp/ddtx
: > $l
: > $t
list.sh | safecat.sh $l
test -s $l || exit 1
cat $l | while read line
do
echo $line | awklist-allfee.sh | mktx.sh | crt.sh | srt.sh | txcat.sh | safecat.sh $t
sert.sh < $t | grep . \
  || v3.sh < $t | sert.sh | grep .
done
