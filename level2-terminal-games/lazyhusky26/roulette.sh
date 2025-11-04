#!/bin/bash

money=100
red=(1 3 5 7 9 12 14 16 18 19 21 23 25 27 30 32 34 36)
black=(2 4 6 8 10 11 13 15 17 20 22 24 26 28 29 31 33 35)

echo "==================="
echo "   Bash Roulette"
echo "==================="
echo "You start with \$$money"
echo

while [[ $money -gt 0 ]]; do
  echo "Current balance: \$$money"
  echo "Place your bet!"
  echo "Options: [red] [black] [number 0–36] or [quit]"
  read -p "> " bet

  if [[ "$bet" == "quit" ]]; then
    echo "You leave the table with \$$money. 💸"
    break
  fi

  read -p "How much do you want to bet? " wager
  if (( wager > money || wager <= 0 )); then
    echo "Invalid bet amount."
    continue
  fi

  echo "Spinning the wheel..."
  sleep 1

  spin=$((RANDOM % 37))
  echo "The ball lands on: $spin"

  color=""
  if [[ " ${red[*]} " =~ " $spin " ]]; then
    color="red"
  elif [[ " ${black[*]} " =~ " $spin " ]]; then
    color="black"
  else
    color="green (0)"
  fi
  echo "Color: $color"

  win=false
  payout=0

  if [[ "$bet" =~ ^[0-9]+$ ]]; then
    if [[ "$bet" -eq "$spin" ]]; then
      payout=$((wager * 35))
      win=true
    fi
  elif [[ "$bet" == "red" && "$color" == "red" ]]; then
    payout=$((wager))
    win=true
  elif [[ "$bet" == "black" && "$color" == "black" ]]; then
    payout=$((wager))
    win=true
  fi

  if $win; then
    echo "You Won! You gain \$$payout"
    money=$((money + payout))
  else
    echo "You lose \$$wager XD"
    money=$((money - wager))
  fi
  echo
done

if [[ $money -le 0 ]]; then
  echo "You're out of money!"
fi

echo "Thanks for playing"
