#!/usr/bin/env bash
# Simple 3-round Rock–Paper–Scissors

set -u

CHOICES=(rock paper scissors)

normalize() {
  case "$1" in
    r|R|rock|Rock) echo rock;;
    p|P|paper|Paper) echo paper;;
    s|S|scissors|Scissors) echo scissors;;
    *) echo invalid;;
  esac
}

beat_of() {
  case "$1" in
    rock) echo scissors;;
    paper) echo rock;;
    scissors) echo paper;;
  esac
}

result() {
  local p=$1 c=$2
  if [[ $p == "$c" ]]; then echo draw; return; fi
  if [[ $(beat_of "$p") == "$c" ]]; then echo win; else echo lose; fi
}

rand_choice() { echo "${CHOICES[$((RANDOM%3))]}"; }

clear

echo "Rock–Paper–Scissors (3 rounds)"
PSCORE=0
CSCORE=0

for round in 1 2 3; do
  echo
  echo "Round $round — Score: You $PSCORE : $CSCORE CPU"
  read -rp "> Your move (r/p/s): " mv
  p=$(normalize "$mv")
  if [[ $p == invalid ]]; then echo "Invalid input."; ((round--)); continue; fi
  c=$(rand_choice)
  res=$(result "$p" "$c")
  case "$res" in
    win)  ((PSCORE++)); echo "You: $p  CPU: $c  → You win this round";;
    lose) ((CSCORE++)); echo "You: $p  CPU: $c  → You lose this round";;
    draw) echo "You: $p  CPU: $c  → Draw";;
  esac

done

echo
if (( PSCORE > CSCORE )); then
  echo "You won the match! ($PSCORE:$CSCORE)"
elif (( CSCORE > PSCORE )); then
  echo "You lost the match. ($PSCORE:$CSCORE)"
else
  echo "It's a draw. ($PSCORE:$CSCORE)"
fi
