#!/bin/bash

gen=$((1 + RANDOM % 100))
echo "A random number has been generated, try to guess it!"

count=0
game=false

while [ "$game" = false ]
do
    read num
    if [ $num -lt $gen ]; then
        count=$((count + 1))
        echo "You guessed too low, try again! Attempt: $count"
    elif [ $num -gt $gen ]; then
        count=$((count + 1))
        echo "You guessed too high, try again! Attempt: $count"
    else
        count=$((count + 1))
        echo " You won! You got it after $count tries."
        game=true
    fi
done

