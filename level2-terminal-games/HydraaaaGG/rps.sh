#!/bin/bash

# Array of choices
choices=("rock" "paper" "scissors")

# Get computer choice randomly
computer_choice=${choices[$RANDOM % 3]}

# Get user choice
read -p "Enter your choice (rock, paper, scissors): " user_choice

# Convert both choices to lowercase (in case user types Rock or ROCK)
user_choice=$(echo "$user_choice" | tr '[:upper:]' '[:lower:]')

# Validate user input
if [[ ! " ${choices[@]} " =~ " ${user_choice} " ]]; then
    echo "Invalid choice: $user_choice"
    exit 1
fi

# Display choices
echo "You chose: $user_choice"
echo "Computer chose: $computer_choice"

# Determine winner
if [[ "$user_choice" == "$computer_choice" ]]; then
    echo "It's a tie!"
elif [[ ("$user_choice" == "rock" && "$computer_choice" == "scissors") || 
        ("$user_choice" == "paper" && "$computer_choice" == "rock") || 
        ("$user_choice" == "scissors" && "$computer_choice" == "paper") ]]; then
    echo "You win!"
else
    echo "You lose!"
fi
