#!/bin/bash
# MATRIX ESCAPE - Dodge falling binary rain (0s and 1s)

rows=12
cols=15
player_col=$((cols/2))
score=0
speed=0.2
lives=3

declare -a grid

init_grid() {
  for ((i=0; i<rows; i++)); do
    grid[$i]=$(printf "%${cols}s" | tr " " " ")
  done
}

draw_grid() {
  clear
  echo "MATRIX ESCAPE | Score: $score | Lives: $lives"
  for ((i=0; i<rows; i++)); do
    echo "${grid[$i]}"
  done
}

spawn_row() {
  new_row=""
  for ((i=0; i<cols; i++)); do
    if ((RANDOM % 8 == 0)); then
      new_row+="$(shuf -e 0 1 -n 1)"
    else
      new_row+=" "
    fi
  done
  grid=("$new_row" "${grid[@]:0:rows-1}")
}

place_player() {
  bottom_row="${grid[$((rows-1))]}"
  # collision check
  if [[ "${bottom_row:$player_col:1}" =~ [01] ]]; then
    ((lives--))
    echo "HIT! Lives left: $lives"
    sleep 0.5
  fi
  bottom_row="${bottom_row:0:$player_col}@${bottom_row:$((player_col+1))}"
  grid[$((rows-1))]="$bottom_row"
}

init_grid

while (( lives > 0 )); do
  spawn_row
  place_player
  draw_grid
  ((score++))

  # input handling
  read -rsn1 -t"$speed" key
  case "$key" in
    a|A) ((player_col>0)) && ((player_col--)) ;;
    d|D) ((player_col<cols-1)) && ((player_col++)) ;;
  esac

  # increase difficulty
  ((score % 15 == 0)) && speed=$(echo "$speed * 0.9" | bc)
done

clear
echo "GAME OVER!"
echo "Final Score: $score"
