#!/bin/bash
# 💣 Mini Minesweeper 5x5

rows=5
cols=5
bombs=5

# Initialize grids
for ((i=0; i<rows*cols; i++)); do
  grid[$i]="."
  revealed[$i]=0
done

# Place bombs randomly
for ((i=0; i<bombs; i++)); do
  while true; do
    pos=$((RANDOM % (rows*cols)))
    if [[ ${grid[$pos]} != "*" ]]; then
      grid[$pos]="*"
      break
    fi
  done
done

draw_board() {
  clear
  echo "   0 1 2 3 4"
  for ((r=0; r<rows; r++)); do
    echo -n "$r "
    for ((c=0; c<cols; c++)); do
      idx=$((r*cols+c))
      if [[ ${revealed[$idx]} -eq 1 ]]; then
        echo -n "${grid[$idx]} "
      else
        echo -n "# "
      fi
    done
    echo
  done
}

while true; do
  draw_board
  read -p "Enter row col (e.g., 1 2): " r c
  idx=$((r*cols+c))

  if [[ ${grid[$idx]} == "*" ]]; then
    clear
    echo "💥 Boom! You hit a mine!"
    break
  fi

  revealed[$idx]=1
  # Count nearby bombs
  count=0
  for dr in {-1..1}; do
    for dc in {-1..1}; do
      nr=$((r+dr))
      nc=$((c+dc))
      if ((nr>=0 && nr<rows && nc>=0 && nc<cols)); then
        [[ ${grid[$((nr*cols+nc))]} == "*" ]] && ((count++))
      fi
    done
  done
  grid[$idx]=$count
done
