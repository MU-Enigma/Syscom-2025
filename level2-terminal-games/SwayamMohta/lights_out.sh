#!/bin/bash
grid=(1 0 1 0 1 0 1 0 1)
echo "=== Lights Out ==="
echo "Toggle lights (1=ON, 0=OFF). Goal: all OFF."

show_grid() {
  echo "${grid[0]} ${grid[1]} ${grid[2]}"
  echo "${grid[3]} ${grid[4]} ${grid[5]}"
  echo "${grid[6]} ${grid[7]} ${grid[8]}"
}

toggle() {
  i=$1
  for j in $i $((i-1)) $((i+1)); do
    if [ $j -ge 0 ] && [ $j -lt 9 ]; then
      grid[$j]=$((1 - ${grid[$j]}))
    fi
  done
}

while :; do
  show_grid
  read -p "Choose position (0-8): " pos
  toggle $pos
  if [[ ${grid[@]} =~ 1 ]]; then
    continue
  else
    echo "🎉 You turned off all lights!"
    break
  fi
done
