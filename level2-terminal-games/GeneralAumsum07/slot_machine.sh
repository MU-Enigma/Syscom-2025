#!/usr/bin/env bash

echo "Welcome to the Slot Machine!"
echo "Press Enter to spin"
read

symbols=("🍒" "🍋" "🍉" "🍇" "⭐" "🔔" "💎")

slot1=${symbols[$(( RANDOM % ${#symbols[@]} ))]}
slot2=${symbols[$(( RANDOM % ${#symbols[@]} ))]}
slot3=${symbols[$(( RANDOM % ${#symbols[@]} ))]}

echo "Spinning..."
sleep 0.5
echo "------------------"
echo "| $slot1 | $slot2 | $slot3 |"
echo "------------------"
sleep 0.5

if [[ "$slot1" == "$slot2" && "$slot2" == "$slot3" ]]; then
  echo "All three match!"
elif [[ "$slot1" == "$slot2" || "$slot2" == "$slot3" || "$slot1" == "$slot3" ]]; then
  echo "You got two matches!"
else
  echo "No matches this time. Try again!"
fi