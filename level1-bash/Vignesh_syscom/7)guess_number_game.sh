#!/bin/bash
# ----- Guess Number Game -----
target=$(( RANDOM % 10 + 1 ))

while true
do
    read -p "Guess a number (1-10): " guess
    if [ $guess -eq $target ]; then
        echo "Correct! The number was $target."
        break
    elif [ $guess -lt $target ]; then
        echo "Too low!"
    else
        echo "Too high!"
    fi
done
