#!/bin/bash

options=("rock" "paper" "scissors" "lizard" "spock")

echo "Choose one: rock, paper, scissors, lizard, spock"
read -r player

player=${player,,}

if [[ ! " ${options[*]} " =~ " $player " ]]; then
  echo "Invalid choice!"
  exit 1
fi

computer=${options[$RANDOM % 5]}

echo "You chose: $player"
echo "Computer chose: $computer"

if [[ "$player" == "$computer" ]]; then
  echo "It's a tie!"
  exit 0
fi

wins() {
  case $1 in
    rock)
      [[ $2 == "scissors" || $2 == "lizard" ]]
      ;;
    paper)
      [[ $2 == "rock" || $2 == "spock" ]]
      ;;
    scissors)
      [[ $2 == "paper" || $2 == "lizard" ]]
      ;;
    lizard)
      [[ $2 == "spock" || $2 == "paper" ]]
      ;;
    spock)
      [[ $2 == "scissors" || $2 == "rock" ]]
      ;;
  esac
}

if wins "$player" "$computer"; then
  echo "You win!"
else
  echo "You Lose!"
fi
