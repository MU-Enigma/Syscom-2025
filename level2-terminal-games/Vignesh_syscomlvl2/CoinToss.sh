#!/bin/bash
# ----- Coin Toss-----

echo "Welcome to the Coin Toss Game!"
echo "Enter your choice (heads or tails):"
read user_choice

# Computer randomly picks heads or tails
options=("heads" "tails")
computer_choice=${options[$RANDOM % 2]}

echo "Coin landed on: $computer_choice"

# Determine result
if [ "$user_choice" == "$computer_choice" ]; then
    echo "You win!"
else
    echo "You lose!"
fi

echo "Thanks for playing!"