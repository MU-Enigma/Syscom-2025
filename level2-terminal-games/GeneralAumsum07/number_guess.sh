#!/usr/bin/env bash
# number_guess.sh - guess a random number between 1 and 10

echo "Welcome to Number Guess!"
secret=$(( RANDOM % 10 + 1 ))
while true; do
  read -p "Guess a number between 1 and 10: " guess

  if [[ $guess -eq $secret ]]; then
    echo "Correct! You guessed it!"
    break
  elif [[ $guess -lt $secret ]]; then
    echo "Too low!"
  else
    echo "Too high!"
  fi
done