#!/bin/bash
# WIRE CONNECT - Simple ASCII puzzle game
# Connect P (power) to L (light) using wire pieces ─ │ ┌ ┐ └ ┘
# Rotate pieces using numbers 1-9

width=5
height=5

# Starting grid (can be randomized later)
grid=(
"┌──L "
"│  │ "
"│  │ "
"P──┘ "
"     "
)

draw_grid() {
  clear
  echo "WIRE CONNECT  |  Rotate pieces to connect P to L"
  echo "Use row & col (e.g., 2 3) to rotate that piece"
  echo
  for ((r=0; r<height; r++)); do
    echo "${grid[$r]}"
  done
}

rotate_piece() {
  local piece=$1
  case $piece in
    "─") echo "│" ;;
    "│") echo "─" ;;
    "┌") echo "┐" ;;
    "┐") echo "┘" ;;
    "┘") echo "└" ;;
    "└") echo "┌" ;;
    *) echo "$piece" ;;
  esac
}

while true; do
  draw_grid
  echo
  read -p "Enter row col to rotate (or q to quit): " r c
  if [[ "$r" == "q" ]]; then exit; fi
  ((r--)); ((c--))
  line="${grid[$r]}"
  piece="${line:$c:1}"
  new_piece=$(rotate_piece "$piece")
  grid[$r]="${line:0:$c}$new_piece${line:$((c+1))}"
  # win condition check (simple static)
  if [[ "${grid[3]:0:3}" == "P──" && "${grid[0]:3:1}" == "L" ]]; then
    draw_grid
    echo
    echo "You connected the wire! Light is ON!"
    break
  fi
done
