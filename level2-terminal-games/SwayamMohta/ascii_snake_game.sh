#!/bin/bash
#  ASCII Snake Game v2 - with borders and growing body

width=20
height=10
snake_x=5
snake_y=5
food_x=$((RANDOM % width))
food_y=$((RANDOM % height))
score=0
sleep_time=0.15

# Snake body arrays
snake_length=1
snake_xs=($snake_x)
snake_ys=($snake_y)

# Draw the grid with border and snake body
draw() {
  clear
  echo "Score: $score"
  # top border
  for ((i=0; i<=width+1; i++)); do echo -n "#"; done
  echo
  # grid
  for ((y=0; y<height; y++)); do
    echo -n "#"
    for ((x=0; x<width; x++)); do
      printed=0
      # snake body
      for ((i=0; i<snake_length; i++)); do
        if [[ ${snake_xs[i]} -eq $x && ${snake_ys[i]} -eq $y ]]; then
          if ((i==0)); then
            echo -n "O"  # head
          else
            echo -n "o"  # body
          fi
          printed=1
          break
        fi
      done
      # food
      if ((printed==0)); then
        if [[ $x -eq $food_x && $y -eq $food_y ]]; then
          echo -n "*"
        else
          echo -n " "
        fi
      fi
    done
    echo "#"
  done
  # bottom border
  for ((i=0; i<=width+1; i++)); do echo -n "#"; done
  echo
}

# Game loop
direction="d"
while true; do
  draw

  # Non-blocking input (0.1 sec delay)
  read -sn1 -t $sleep_time key && direction=$key

  # Move snake: shift body
  for ((i=snake_length-1; i>0; i--)); do
    snake_xs[i]=${snake_xs[i-1]}
    snake_ys[i]=${snake_ys[i-1]}
  done

  # Move head
  case $direction in
    w) ((snake_ys[0]--)) ;;
    s) ((snake_ys[0]++)) ;;
    a) ((snake_xs[0]--)) ;;
    d) ((snake_xs[0]++)) ;;
    q) echo "Game Over!"; exit ;;
  esac

  snake_x=${snake_xs[0]}
  snake_y=${snake_ys[0]}

  # Check wall collision
  if ((snake_x < 0 || snake_x >= width || snake_y < 0 || snake_y >= height)); then
    echo " You hit the wall! Final Score: $score"
    exit
  fi

  # Check self collision
  for ((i=1; i<snake_length; i++)); do
    if [[ ${snake_xs[i]} -eq $snake_x && ${snake_ys[i]} -eq $snake_y ]]; then
      echo " You hit yourself! Final Score: $score"
      exit
    fi
  done

  # Eat food
  if [[ $snake_x -eq $food_x && $snake_y -eq $food_y ]]; then
    ((score++))
    ((snake_length++))
    snake_xs+=(${snake_xs[-1]})
    snake_ys+=(${snake_ys[-1]})
    food_x=$((RANDOM % width))
    food_y=$((RANDOM % height))
  fi
done
as