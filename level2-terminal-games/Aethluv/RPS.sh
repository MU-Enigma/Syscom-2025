#!/bin/bash
echo "Choose one: rock, paper, or scissors"
read -p "Your choice: " player
player=$(echo "$player" | tr '[:upper:]' '[:lower:]')
choices=("rock" "paper" "scissors")
computer=${choices[$RANDOM % 3]}
echo "Computer chose: $computer"
if [[ "$player" == "$computer" ]]; then
    echo "It's a tie!"
elif [[ ("$player" == "rock" && "$computer" == "scissors") || \
        ("$player" == "scissors" && "$computer" == "paper") || \
        ("$player" == "paper" && "$computer" == "rock") ]]; then
    echo "You win!"
else
    echo "You lose!"
fi
