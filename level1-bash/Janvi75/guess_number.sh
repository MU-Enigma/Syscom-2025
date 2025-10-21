#!/bin/bash

# Bash script for a simple guessing game
target=$(( RANDOM % 10 + 1 ))
guess=0

echo "Guess a number between 1 and 10!"

while [ $guess -ne $target ]
do
    read -p "Enter your guess: " guess
    if [ $guess -lt $target ]
    then
        echo "Too low!"
    elif [ $guess -gt $target ]
    then
        echo "Too high!"
    else
        echo "You guessed it right!"
    fi
done
