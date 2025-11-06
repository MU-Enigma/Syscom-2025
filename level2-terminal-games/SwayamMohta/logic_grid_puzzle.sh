#!/bin/bash
echo "=== Logic Grid Puzzle ==="
echo "3 friends (A, B, C) have pets (Dog, Cat, Fish)."
echo "Clues:"
echo "1. A doesn’t have a cat."
echo "2. B has a fish."
echo "Who has the dog?"
read -p "Enter name: " ans
if [[ "$ans" == "A" ]]; then
  echo " Correct! A has the dog."
else
  echo " Wrong! Correct answer: A"
fi
