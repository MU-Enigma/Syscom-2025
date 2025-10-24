#!/bin/bash

# Number Guessing Game by Charith
target=$(( RANDOM % 10 + 1 ))
attempts=0

echo "🎯 Welcome to the Number Guessing Game!"
echo "I'm thinking of a number between 1 and 10. Can you guess it?"

while true; do
    read -p "Enter your guess: " guess
    ((attempts++))

    if [[ $guess -eq $target ]]; then
        echo "🎉 Correct! You guessed it in $attempts tries!"
        break
    elif [[ $guess -lt $target ]]; then
        echo "Too low! Try again."
    else
        echo "Too high! Try again."
    fi
done
