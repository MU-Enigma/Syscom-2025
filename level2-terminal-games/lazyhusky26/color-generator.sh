#!/bin/bash

echo "Generating 10 colors..."
echo "------------------------------------"

for i in {1..10}; do
  hex=$(printf '#%06X\n' $((RANDOM*RANDOM % 16777216)))

  r=$((16#${hex:1:2}))
  g=$((16#${hex:3:2}))
  b=$((16#${hex:5:2}))

  printf "\e[48;2;%d;%d;%dm  %-10s  \e[0m\n" "$r" "$g" "$b" "$hex"

  sleep 0.2
done

echo "------------------------------------"
echo "Done!"
