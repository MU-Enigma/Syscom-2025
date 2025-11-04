#!/bin/bash

# Generate a random number between 1 and 10
NUMBER=$((RANDOM % 10 + 1))

# Initialize attempts counter
attempts=0

# Start the game loop
echo "Guess a number between 1 and 10"

# Loop until the user guesses the correct number
while true; do
    read -p "Your guess: " GUESS
    attempts=$((attempts + 1))

    if [ $GUESS -eq $NUMBER ]; then
        echo "Right! The number was $NUMBER. You guessed it in $attempts attempts."
        break
    elif [ $GUESS -lt $NUMBER ]; then
        echo "Too low! Try again."
    else
        echo "Too high! Try again."
    fi
done
