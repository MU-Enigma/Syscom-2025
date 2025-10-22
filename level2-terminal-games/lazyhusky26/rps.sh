#!/bin/bash

# Rock Paper Scissors Game

options=("rock" "paper" "scissors")
computer_choice=${options[$RANDOM % 3]}

echo "Welcome to Rock, Paper, Scissors!"
echo "Choose one: rock, paper, or scissors"
read -p "Your choice: " user_choice

user_choice=$(echo "$user_choice" | tr '[:upper:]' '[:lower:]')

if [[ ! " ${options[@]} " =~ " ${user_choice} " ]]; then
    echo "Invalid choice. Please choose rock, paper, or scissors."
    exit 1
fi

echo "Computer chose: $computer_choice"

if [[ "$user_choice" == "$computer_choice" ]]; then
    echo "It's a tie!"
elif [[ ("$user_choice" == "rock" && "$computer_choice" == "scissors") ||
        ("$user_choice" == "paper" && "$computer_choice" == "rock") ||
        ("$user_choice" == "scissors" && "$computer_choice" == "paper") ]]; then
    echo "You win!"
else
    echo "You lose!"
fi
