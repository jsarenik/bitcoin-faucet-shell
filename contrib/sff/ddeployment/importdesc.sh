cat descriptors | while read desc
do
bch.sh listdescriptors true | grep $desc && continue
gdi=$(gdi.sh "$desc")
cs=$(echo $gdi | jq -r .checksum)
rode=$(echo $gdi | jq -r .descriptor)
#echo $rode
#echo $cs
bch.sh deriveaddresses "$rode" 2>/dev/null
{
cat <<EOF
[{"desc": "$desc#$cs", "timestamp":"now"}]
EOF
} | bch.sh -stdin importdescriptors
done
