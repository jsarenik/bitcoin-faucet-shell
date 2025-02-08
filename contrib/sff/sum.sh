#!/bin/sh

awk '{sum+=$3} END {printf("%.8f\n", sum)}' $1
