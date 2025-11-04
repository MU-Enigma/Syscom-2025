#!/bin/bash
clear
echo "=== Rock Paper Scissors ==="
echo "Choose one: rock, paper, or scissors"
read -p "Your choice: " player
options=("rock" "paper" "scissors")
computer=${options[$((RANDOM%3))]}
echo "Computer chose: $computer"
if [ "$player" = "$computer" ]; then
    echo "It's a draw!"
elif [ "$player" = "rock" ] && [ "$computer" = "scissors" ] ||
     [ "$player" = "scissors" ] && [ "$computer" = "paper" ] ||
     [ "$player" = "paper" ] && [ "$computer" = "rock" ]; then
    echo "You win!"
else
    echo "Computer wins!"
fi