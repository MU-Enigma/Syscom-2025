#!/bin/bash
# ZOMBIE RUN - survive as long as possible

width=15
height=8
player_x=7
player_y=7
zombie_x=0
zombie_y=0
turns=0

while true; do
  clear
  echo "TURN: $turns"
  for ((y=0; y<height; y++)); do
    for ((x=0; x<width; x++)); do
      if ((x==player_x && y==player_y)); then printf "@"
      elif ((x==zombie_x && y==zombie_y)); then printf "Z"
      else printf "."
      fi
    done
    echo
  done
  read -rsn1 -t0.5 key
  case $key in
    w) ((player_y>0)) && ((player_y--));;
    s) ((player_y<height-1)) && ((player_y++));;
    a) ((player_x>0)) && ((player_x--));;
    d) ((player_x<width-1)) && ((player_x++));;
  esac
  ((zombie_x<player_x)) && ((zombie_x++))
  ((zombie_x>player_x)) && ((zombie_x--))
  ((zombie_y<player_y)) && ((zombie_y++))
  ((zombie_y>player_y)) && ((zombie_y--))
  ((turns++))
  if ((zombie_x==player_x && zombie_y==player_y)); then
    clear
    echo "💀 Caught after $turns turns!"
    break
  fi
done
