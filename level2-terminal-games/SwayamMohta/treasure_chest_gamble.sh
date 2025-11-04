#!/bin/bash
echo "=== Treasure Chest Gamble ==="
echo "Pick a chest (1, 2, or 3):"
treasure=$((RANDOM % 3 + 1))
read -p "Your choice: " choice
if [ "$choice" -eq "$treasure" ]; then
  echo "💎 You found the treasure!"
else
  echo "💀 Empty chest! Treasure was in $treasure."
fi
