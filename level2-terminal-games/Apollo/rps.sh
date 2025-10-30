#!/bin/bash

echo "Enter your choice: "
read choice

choices=("rock" "paper" "scissors")
computer_choice=${choices[$((RANDOM % 3))]}

echo "You chose: $choice"
echo "The computer chose: $computer_choice"

if [ "$choice" == "$computer_choice" ]; then
  echo "It's a tie!"
elif { [ "$user_choice" == "rock" ] && [ "$computer_choice" == "scissors" ]; } ||
     { [ "$user_choice" == "paper" ] && [ "$computer_choice" == "rock" ]; } ||
     { [ "$user_choice" == "scissors" ] && [ "$computer_choice" == "paper" ]; }; then
    echo "You win!"
else
    echo "Computer wins!"
fi
