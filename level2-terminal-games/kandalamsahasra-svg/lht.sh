#!/bin/bash

options=("lady" "hunter" "tiger")
computer=${options[$((RANDOM % 3))]}

echo "Choose lady, hunter, or tiger:"
read player

echo "Opponent chose: $computer"

if [ "$player" = "$computer" ]; then
    echo "It's a tie!"
elif [ "$player" = "lady" ] && [ "$computer" = "hunter" ] ||
     [ "$player" = "hunter" ] && [ "$computer" = "tiger" ] ||
     [ "$player" = "tiger" ] && [ "$computer" = "lady" ]; then
    echo "You win"
else
    echo "You lose"
fi
