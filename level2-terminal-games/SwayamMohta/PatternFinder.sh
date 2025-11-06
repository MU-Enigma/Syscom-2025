#!/bin/bash
# Pattern Finder Game
echo "=== Pattern Finder ==="
patterns=("2 4 6 8 ?" "1 1 2 3 5 ?" "3 6 12 24 ?" "10 20 40 80 ?")
answers=(10 8 48 160)
rand=$((RANDOM % 4))
echo "Find the next number:"
echo "${patterns[$rand]}"
read -p "Your answer: " ans
if [ "$ans" -eq "${answers[$rand]}" ]; then
  echo " Correct!"
else
  echo "Wrong! Correct answer: ${answers[$rand]}"
fi
