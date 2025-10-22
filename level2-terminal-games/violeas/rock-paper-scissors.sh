#!/bin/bash

# Rock Paper Scissors game - simple version

echo "Welcome to Rock Paper Scissors!"

while true
do
  echo ""
  echo "Choose rock, paper, or scissors (or type quit to stop):"
  read player

  # make input lowercase
  player=$(echo $player | tr 'A-Z' 'a-z')

  if [ "$player" = "quit" ]; then
    echo "Goodbye!"
    break
  fi

  if [ "$player" != "rock" ] && [ "$player" != "paper" ] && [ "$player" != "scissors" ]; then
    echo "Invalid choice. Try again."
    continue
  fi

  # computer chooses
  num=$(( RANDOM % 3 ))
  if [ $num -eq 0 ]; then
    computer="rock"
  elif [ $num -eq 1 ]; then
    computer="paper"
  else
    computer="scissors"
  fi

  echo "Computer chose: $computer"

  if [ "$player" = "$computer" ]; then
    echo "It's a tie!"
  elif [ "$player" = "rock" ] && [ "$computer" = "scissors" ]; then
    echo "You win!"
  elif [ "$player" = "paper" ] && [ "$computer" = "rock" ]; then
    echo "You win!"
  elif [ "$player" = "scissors" ] && [ "$computer" = "paper" ]; then
    echo "You win!"
  else
    echo "Computer wins!"
  fi
done
