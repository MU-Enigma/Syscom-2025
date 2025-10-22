#!/bin/bash

target=$(( RANDOM % 100 + 1 ))

echo "🎯 Welcome to the Number Guessing Game!"
echo "I'm thinking of a number between 1 and 100."

attempts=0

while true; do
    read -p "Enter your guess: " guess

    if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
        echo "Enter a valid number."
        continue
    fi

    ((attempts++))

    if (( guess < target )); then
        echo "Too low!"
    elif (( guess > target )); then
        echo "Too high!"
    else
        echo "Correct! You guessed it in $attempts attempts."
        break
    fi
done
