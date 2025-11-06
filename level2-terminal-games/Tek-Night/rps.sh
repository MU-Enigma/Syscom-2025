#!/bin/bash

echo "Welcome to rock paper scissor!"
echo "Choose rock, paper or scissors:"

read choice

comp_num=$((RANDOM%3+1))

if [ $comp_num -eq 1 ]; then
    comp="rock"
elif [ $comp_num -eq 2 ]; then
    comp="paper"
else
    comp="scissors"
fi

echo "Computer chose: $comp"

if [ "$choice" == "$comp" ]; then
    echo "It's a tie!"
elif [ "$choice" == "rock" ] && [ "$comp" == "scissors" ]; then
    echo "You win!"
elif [ "$choice" == "paper" ] && [ "$comp" == "rock" ]; then
    echo "You win!"
elif [ "$choice" == "scissors" ] && [ "$comp" == "paper" ]; then
    echo "You win!"
else
    echo "You lose!"
fi