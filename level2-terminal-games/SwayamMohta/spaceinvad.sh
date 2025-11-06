#!/bin/bash
# SPACE ESCAPE - Simple Bash terminal game (no emojis)
# Move left (a), right (d), or stay (Enter)
# Avoid falling asteroids (O)
# Game ends after 3 hits

width=11
height=10
player_pos=$((width/2))
score=0
lives=3

# Initialize grid
init_grid() {
  for ((r=0; r<height; r++)); do
    grid[$r]=$(printf "%${width}s" "")
  done
}

# Draw the grid
draw_grid() {
  clear
  echo "SPACE ESCAPE | Score: $score | Lives: $lives"
  printf "+"
  for ((i=0; i<width; i++)); do printf "-"; done
  echo "+"
  for ((r=0; r<height; r++)); do
    printf "|"
    echo "${grid[$r]}"
    printf "|"
    echo
  done
  printf "+"
  for ((i=0; i<width; i++)); do printf "-"; done
  echo "+"
  echo "Controls: a = left, d = right, Enter = stay"
}

# Random asteroid spawn
spawn_asteroid() {
  if (( RANDOM % 100 < 30 )); then
    col=$((RANDOM % width))
    row="${grid[0]}"
    grid[0]=$(echo "$row" | sed "s/./O/$((col+1))")
  fi
}

# Move asteroids down
move_asteroids_down() {
  for ((r=height-1; r>0; r--)); do
    grid[$r]="${grid[$((r-1))]}"
  done
  grid[0]=$(printf "%${width}s" "")
}

# Place player and handle collision
place_player() {
  grid[$((height-1))]=$(printf "%${width}s" "")
  row="${grid[$((height-1))]}"
  if [[ "${row:$player_pos:1}" == "O" ]]; then
    ((lives--))
    echo "You got hit! Lives left: $lives"
    sleep 1
    if (( lives == 0 )); then
      clear
      echo "====================="
      echo "GAME OVER"
      echo "Final Score: $score"
      echo "====================="
      exit
    fi
  fi
  row="${grid[$((height-1))]}"
  grid[$((height-1))]="${row:0:$player_pos}^${row:$((player_pos+1))}"
}

# Main game loop
init_grid
while true; do
  spawn_asteroid
  move_asteroids_down
  place_player
  draw_grid
  ((score+=10))

  read -n1 -t0.6 key
  case "$key" in
    a|A) ((player_pos>0)) && ((player_pos--)) ;;
    d|D) ((player_pos<width-1)) && ((player_pos++)) ;;
    *) ;; # stay
  esac
done
