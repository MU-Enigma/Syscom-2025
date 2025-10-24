#!/bin/bash
clear
echo "Number Guess Duel (You vs Computer)"
computer_num=$((RANDOM%10+1))
read -p "Enter your guess (1–10): " player_guess
if ! [[ "$player_guess" =~ ^[0-9]+$ ]] || [ "$player_guess" -lt 1 ] || [ "$player_guess" -gt 10 ]; then
    echo "Invalid input! Please enter a number between 1 and 10."
    exit 1
fi
echo "The computer chose: $computer_num"
if [ "$player_guess" -eq "$computer_num" ]; then
    echo "You guessed it! You win!"
else
    diff=$((player_guess - computer_num))
    if [ "$diff" -lt 0 ]; then
        diff=$((diff * -1))
    fi
    echo "Wrong guess! You were off by $diff."
fi