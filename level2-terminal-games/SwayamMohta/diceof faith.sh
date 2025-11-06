#!/bin/bash
# DUNGEON ROLL - Simple dice-based adventure

health=100
gold=0
level=1

clear
echo "🎲 DUNGEON ROLL 🎲"
echo "Survive through 10 levels by defeating monsters."
echo "You start with 100 health and 0 gold."
read -p "Press Enter to begin..."

while (( level <= 10 && health > 0 )); do
  clear
  echo "====== Level $level ======"
  monster=$(( (RANDOM % 6) + 4 ))  # monster strength (4–9)
  echo "A monster appears! Strength: $monster"
  read -p "Press Enter to roll dice..."
  
  d1=$(( (RANDOM % 6) + 1 ))
  d2=$(( (RANDOM % 6) + 1 ))
  total=$((d1 + d2))
  
  echo "You rolled: $d1 + $d2 = $total"

  if (( total >= monster )); then
    gain=$(( (RANDOM % 20) + 10 ))
    gold=$((gold + gain))
    echo "You defeated the monster! Gained $gain gold."
  else
    loss=$(( (RANDOM % 15) + 5 ))
    health=$((health - loss))
    echo "You took $loss damage! Health: $health"
  fi

  # random event
  event=$((RANDOM % 5))
  if (( event == 0 )); then
    heal=$(( (RANDOM % 10) + 5 ))
    health=$((health + heal))
    echo "You found a potion! +$heal health."
  elif (( event == 1 )); then
    echo "A trap! -10 health."
    health=$((health - 10))
  elif (( event == 2 )); then
    echo "A merchant sells a potion for 10 gold."
    if (( gold >= 10 )); then
      read -p "Buy potion? (y/n): " buy
      if [[ $buy == "y" ]]; then
        gold=$((gold - 10))
        health=$((health + 15))
        echo "You feel better! +15 health."
      fi
    fi
  fi

  ((level++))
  sleep 1.5
done

clear
echo "====== GAME OVER ======"
echo "Gold collected: $gold"
echo "Final health: $health"
if (( health > 0 )); then
  echo "You survived the dungeon! 🏆"
else
  echo "You perished at level $((level-1))... 💀"
fi
