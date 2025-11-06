#!/bin/bash

options=("rock" "paper" "scissors")
computer=${options[$((RANDOM % 3))]}

echo "Choose rock, paper, or scissors:"
read player

echo "Opponent chose: $computer"

if [ "$player" = "$computer" ]; then
    echo "It's a tie!"
elif [ "$player" = "rock" ] && [ "$computer" = "scissors" ] ||
     [ "$player" = "paper" ] && [ "$computer" = "rock" ] ||
     [ "$player" = "scissors" ] && [ "$computer" = "paper" ]; then
    echo "You win"
else
    echo "You lose"
fi
