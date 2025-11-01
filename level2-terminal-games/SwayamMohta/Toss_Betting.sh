#!/bin/bash
flip=$((RANDOM % 2))
read -p "Bet on Heads (1) or Tails (2): " bet
if [ "$bet" -eq "$flip" ]; then
    echo "You win! It's $([[ $flip -eq 0 ]] && echo "Heads" || echo "Tails")"
else
    echo "You lose! It was $([[ $flip -eq 0 ]] && echo "Heads" || echo "Tails")"
fi
