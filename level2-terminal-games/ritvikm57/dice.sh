#!/usr/bin/env bash
# die-guess.sh — Simple Dice Guessing Game
# You guess first; then the die rolls and reveals if you were right.

set -euo pipefail

SCORE=0
ROUND=0
BEST_STREAK=0
STREAK=0

print_dice() {
  case $1 in
    1) cat <<'DICE'
+-------+
|       |
|   •   |
|       |
+-------+
DICE
;;
    2) cat <<'DICE'
+-------+
| •     |
|       |
|     • |
+-------+
DICE
;;
    3) cat <<'DICE'
+-------+
| •     |
|   •   |
|     • |
+-------+
DICE
;;
    4) cat <<'DICE'
+-------+
| •   • |
|       |
| •   • |
+-------+
DICE
;;
    5) cat <<'DICE'
+-------+
| •   • |
|   •   |
| •   • |
+-------+
DICE
;;
    6) cat <<'DICE'
+-------+
| •   • |
| •   • |
| •   • |
+-------+
DICE
;;
  esac
}

roll_die() {
  echo $(( (RANDOM % 6) + 1 ))
}

trap 'echo "\nThanks for playing!"; exit 0' SIGINT

clear
cat <<INTRO
*** Dice Guessing Game ***
Guess the face of the die (1–6). Then the die will roll and reveal the truth.
Type 'q' to quit.
-------------------------------------------
INTRO

while true; do
  ((ROUND++))
  echo "Round $ROUND"

  read -rp "Your guess (1-6, or q to quit): " guess || break
  if [[ $guess == 'q' || $guess == 'Q' ]]; then
    break
  fi
  if ! [[ $guess =~ ^[1-6]$ ]]; then
    echo "Invalid input. Enter 1–6."; continue
  fi

  echo -n "Rolling the die"
  for i in {1..3}; do
    echo -n "."
    sleep 0.5
  done
  echo -e "\n"

  roll=$(roll_die)
  print_dice "$roll"

  if [[ $guess -eq $roll ]]; then
    ((SCORE++))
    ((STREAK++))
    echo "Correct! Your score: $SCORE (Streak: $STREAK)"
  else
    BEST_STREAK=$(( STREAK > BEST_STREAK ? STREAK : BEST_STREAK ))
    STREAK=0
    echo "Wrong! The die showed $roll."
  fi
  echo "-------------------------------------------"
done

BEST_STREAK=$(( STREAK > BEST_STREAK ? STREAK : BEST_STREAK ))
echo -e "\nFinal score: $SCORE | Best streak: $BEST_STREAK"
echo "Goodbye!"
