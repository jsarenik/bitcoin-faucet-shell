uncom() {
cat <<EOF
pk($key)
sh(pk($key))
combo($key)
EOF
}

doall() {
cat <<EOF
pk($key)
sh(pk($key))
wsh(pk($key))
pkh($key)
sh(pkh($key))
wsh(pkh($key))
sh(wsh(pkh($key)))
wpkh($key)
sh(wpkh($key))
tr($key)
EOF
}

key=cTGPTExB3y45JNFMxRRDKKXfycqS3YswAidzVrdJUPeZ1XZwVcXF; doall
key=92scStC9Ajc8miWzJzeCrTrYVEZGeHHXQ3dvosDJZ2xdhzA9Rik; uncom

# 0001
#key=KwDiBf89QgGbjEhKnhXJuH7LrciVrZi3qYjgd9M7rFU73sVHnoWn; doall
# FF..3F
#key=L5oLkpV3aqBjhki6LmvChTCV6odsp4SXM6FfU2Gppt5kEqeonMfk; doall
