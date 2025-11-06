#!/bin/bash

echo "Rock, Paper, Scissors!"
echo "Choose one: rock, paper, or scissors"
read -p "Your choice: " user_choice

choices=("rock" "paper" "scissors")
computer_choice=${choices[$((RANDOM % 3))]}

echo "Computer chose: $computer_choice"

if [ "$user_choice" == "$computer_choice" ]; then
    echo "It's a tie!"
elif [ "$user_choice" == "rock" ] && [ "$computer_choice" == "scissors" ]; then
    echo "You win!"
elif [ "$user_choice" == "paper" ] && [ "$computer_choice" == "rock" ]; then
    echo "You win!"
elif [ "$user_choice" == "scissors" ] && [ "$computer_choice" == "paper" ]; then
    echo "You win!"
else
    echo "You lose!"
fi
