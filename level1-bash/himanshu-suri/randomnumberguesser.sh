#!/bin/bash

target=$(( (RANDOM % 100) + 1 ))

echo "Pick a random number between 1 and 100"

while true; do
    read guess
    if [ $guess -eq $target ]; then
        echo "You guessed it!"
        break
    elif [ $guess -lt $target ]; then
        echo "Too low, try again!"
    else
        echo "Too high, try again!"
    fi
done
 
