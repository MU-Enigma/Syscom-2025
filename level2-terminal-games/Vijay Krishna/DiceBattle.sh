#!/bin/bash

echo "Simple Dice Battle!"
echo "You and the computer will each roll a 20-sided die."
echo "Press Enter to roll..."
read

# Use (RANDOM % 20 + 1) to get a number from 1 to 20
player_roll=$((RANDOM % 20 + 1))
computer_roll=$((RANDOM % 20 + 1))

echo ""
echo "You rolled a: $player_roll"
echo "Computer rolled a: $computer_roll"
echo ""

# Determine the winner
if [ "$player_roll" -gt "$computer_roll" ]; then
    echo "You rolled higher! You win!"
elif [ "$computer_roll" -gt "$player_roll" ]; then
    echo "The computer rolled higher! You lose."
else
    echo "It's a tie!"
fi

read -p "Press Enter to close..."