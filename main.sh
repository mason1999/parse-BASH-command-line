#! /usr/bin/bash

. ./parse-command-line.sh "$@"
shift $ARGC

echo "ARGC: $ARGC"
declare -a x
print_array "map_long_to_short"
print_array "map_short_type"
print_array "map_runtime"
print_array "x"
echo $1
