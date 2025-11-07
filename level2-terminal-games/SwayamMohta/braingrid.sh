#!/bin/bash
# BRAINGRID
size=4
declare -A g
for ((i=0;i<size;i++)); do for ((j=0;j<size;j++)); do g[$i,$j]=$((RANDOM%2)); done; done

while true; do
  clear
  for ((i=0;i<size;i++)); do
    for ((j=0;j<size;j++)); do printf "%s " "${g[$i,$j]}"; done; echo
  done
  solved=1
  for v in "${g[@]}"; do ((v==0)) && solved=0; done
  ((solved)) && { echo "🎉 Puzzle solved!"; break; }
  read -p "Enter row col (0-$((size-1))): " x y
  for dx in -1 0 1; do for dy in -1 0 1; do
    ((nx=x+dx, ny=y+dy))
    ((nx>=0 && nx<size && ny>=0 && ny<size)) && ((g[$nx,$ny]=1-g[$nx,$ny]))
  done; done
done
