#!/bin/bash

# Task 7 - Guess the Number Game

# Generate a random number between 1 and 10
target=$(( RANDOM % 10 + 1 ))

echo "Welcome to the Guess the Number Game!"
echo "I have picked a number between 1 and 10. Can you guess it?"

# Loop until the user guesses correctly
while true
do
    echo "Enter your guess:"
    read guess

    if [ $guess -lt $target ]; then
        echo "Too low! Try again."
    elif [ $guess -gt $target ]; then
        echo "Too high! Try again."
    else
        echo "Congratulations! You guessed the number $target."
        break
    fi
done