#!/bin/bash
# coin-flip.sh - Simple coin flip game

echo "Welcome to the Coin Flip Game!"
read -p "Guess (heads/tails): " guess

flip=$((RANDOM % 2))
if [ $flip -eq 0 ]; then
  result="heads"
else
  result="tails"
fi

echo "The coin landed on: $result"

if [ "$guess" == "$result" ]; then
  echo "You guessed right!"
else
  echo "Wrong guess!"
fi
