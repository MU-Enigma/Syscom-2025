#!/usr/bin/env bash
# rps.sh - simple Rock Paper Scissors (one round)

echo "Welcome to Rock, Paper, Scissors!"
choices=("rock" "paper" "scissors")

while true; do
  read -p "Choose rock, paper, or scissors: " user
  user="${user,,}"
  if [[ "$user" == "rock" || "$user" == "paper" || "$user" == "scissors" ]]; then
    break
  fi
  echo "Please enter rock, paper, or scissors."
done

comp_index=$(( RANDOM % 3 ))
comp="${choices[$comp_index]}"

echo "Computer chose: $comp"

if [[ "$user" == "$comp" ]]; then
  echo "It's a tie!"
else
  if [[ ( "$user" == "rock" && "$comp" == "scissors" ) ||
        ( "$user" == "paper" && "$comp" == "rock" ) ||
        ( "$user" == "scissors" && "$comp" == "paper" ) ]]; then
    echo "You win!"
  else
    echo "You lose!"
  fi
fi