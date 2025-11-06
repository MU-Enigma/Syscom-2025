#!/bin/bash

number=$((RANDOM % 100 + 1))
tries=0

echo "🎯 Guess the number (1–100)!"

while true; do
  echo "Enter your guess: "
  read guess
  ((tries++))

  if ((guess == number)); then
    echo "✅ Correct! You guessed it in $tries tries."
    break
  elif ((guess < number)); then
    echo "⬆️ Too low!"
  else
    echo "⬇️ Too high!"
  fi
done
