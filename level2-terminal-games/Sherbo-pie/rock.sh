#!/bin/bash

echo "Welcome to the rock-paper-scissors game"
echo "Choose your contender(rock,paper,scissors): "
read choice_u
num=$((RANDOM % 3 +1))

if [ "$num" -eq 1 ]; then
     choice_c="rock"
elif [ "$num" -eq 2 ]; then
     choice_c="paper"
else 
     choice_c="scissors"
fi

echo "The computer chose: $choice_c"


if [ "$choice_u" = "$choice_c" ]; then
     echo "Its a draw!"
elif [[ ("$choice_u" = "rock" && "$choice_c" = "scissors") || ("$choice_u" = "paper" && "$choice_c" = "rock") || ("$choice_u" = "scissors" && "$choice_c" = "paper") ]]; then
     echo "Congrats! You won!"
else
     echo "Better luck next time!"
fi
