#!/bin/bash
echo "=== Lucky Door Game ==="
treasure=$((RANDOM % 3 + 1))
echo "Choose a door (1, 2, 3):"
read choice
if [ "$choice" -eq "$treasure" ]; then
  echo "🎉 You found the treasure!"
else
  echo "🚪 Empty room. Treasure was behind door $treasure."
fi
