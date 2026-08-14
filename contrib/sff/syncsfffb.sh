for i in *.sh; do cmp ~/bin/$i $i || cp -v ~/bin/$i .; done
