for i in *.sh; do test "$i" = "safecat.sh" && continue; cmp ~/bin/$i $i || cp -v ~/bin/$i .; done
git checkout awklist*
