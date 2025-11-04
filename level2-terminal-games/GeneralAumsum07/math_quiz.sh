#!/usr/bin/env bash

echo "Welcome to Math Quiz!"

read -p "How many questions do you want? " Q
if ! [[ "$Q" =~ ^[0-9]+$ ]] || [ "$Q" -le 0 ]; then
  echo "Please enter a positive integer."
  exit 1
fi

score=0

for (( i=1; i<=Q; i++ )); do
  a=$(( RANDOM % 20 + 1 ))
  b=$(( RANDOM % 20 + 1 ))
  op_index=$(( RANDOM % 3 ))
  case $op_index in
    0) op="+"; ans=$(( a + b ));;
    1) op="-"; ans=$(( a - b ));;
    2) op="*"; ans=$(( a * b ));;
  esac

  echo
  read -p "Q$i) What is $a $op $b ? " resp
  if ! [[ "$resp" =~ ^-?[0-9]+$ ]]; then
    echo "Invalid answer (expecting integer). Skipping."
    continue
  fi

  if [ "$resp" -eq "$ans" ]; then
    echo "Correct!"
    ((score++))
  else
    echo "Wrong. Correct answer: $ans"
  fi
done

echo
echo "Quiz complete! Score: $score / $Q"