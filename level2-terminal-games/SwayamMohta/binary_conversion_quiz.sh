#!/bin/bash
echo "=== Binary Conversion Quiz ==="
num=$((RANDOM % 50 + 1))
echo "Convert this number to binary: $num"
read -p "Your answer: " user
bin=$(echo "obase=2; $num" | bc)
if [ "$user" == "$bin" ]; then
  echo " Correct!"
else
  echo " Wrong! Correct binary: $bin"
fi
