#!/bin/bash
echo "=== Mystery Box Challenge ==="
coins=100
echo "You start with $coins coins."
while true; do
  echo "Pick a box (1–5) or 0 to quit:"
  read box
  [ "$box" -eq 0 ] && break
  change=$(( (RANDOM % 41) - 20 )) # -20 to +20
  coins=$((coins + change))
  echo "This box changed your coins by $change. Total = $coins"
done
echo "Game over. Final coins: $coins"
