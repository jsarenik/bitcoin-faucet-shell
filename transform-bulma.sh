#!/bin/sh

cat tmp/bulma/css/bulma.css \
  | sed -e "s/#00d1b2/#E46A00/g" \
	-e "s/#b5b5b5/#b15200/g" \
	-e "s/rgba(10, 10, 10,/rgba(28, 28, 28,/g" \
	-e "s/#485fc7/#3273dc/g" \
	-e "s/#da1039/#f14668/g" \
	-e "s/#363636/#1C1C1C/g" \
	-e "s/#1c1c1c/#030303/g" \
	-e "s/#009e86/#b15200/g" \
	-e "s/#3449a8/#205bbc/g" \
	-e "s/#0a0a0a/#1C1C1C/g" \
	-e "s/box-shadow: 0 0 0 0.125em rgba(0, 209, 178, 0.25);$/box-shadow: 0 0 0 0.225em rgba(28, 28, 28, 0.25);/"

cat css-add
