#!/bin/bash

# Number Guessing Game
# Author: Janvi75
# Description: Guess the secret number between 1 and 100.

# Generate a random number between 1 and 100
secret=$(( RANDOM % 100 + 1 ))
attempts=0

echo "=================================="
echo "🎯 Welcome to the Number Guessing Game!"
echo "=================================="
echo "I'm thinking of a number between 1 and 100."
echo "Can you guess what it is?"
echo ""

while true; do
    read -p "Enter your guess: " guess

    # Validate input (must be a number)
    if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
        echo "❌ Please enter a valid number!"
        continue
    fi

    ((attempts++))

    if (( guess < secret )); then
        echo "🔼 Too low! Try again."
    elif (( guess > secret )); then
        echo "🔽 Too high! Try again."
    else
        echo "🎉 Congratulations! You guessed it in $attempts attempts!"
        break
    fi
done

echo ""
echo "Thanks for playing! 👋"
