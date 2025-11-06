#!/bin/bash
# TARGET SHOOTER
width=20; height=8; score=0; time_left=15
tx=$((RANDOM%width)); ty=$((RANDOM%height)); cx=$((width/2)); cy=$((height/2))
stty -echo -icanon time 0 min 0; trap "stty echo icanon; clear; exit" INT

while ((time_left>0)); do
  clear; echo "Time:$time_left | Score:$score"
  for ((y=0;y<height;y++)); do
    for ((x=0;x<width;x++)); do
      if ((x==tx&&y==ty)); then printf "X"
      elif ((x==cx&&y==cy)); then printf "+"
      else printf "."
      fi
    done; echo
  done
  read -rsn1 -t0.2 key
  case $key in
    w)((cy>0))&&((cy--));;
    s)((cy<height-1))&&((cy++));;
    a)((cx>0))&&((cx--));;
    d)((cx<width-1))&&((cx++));;
    " ") if ((cx==tx&&cy==ty)); then ((score++)); tx=$((RANDOM%width)); ty=$((RANDOM%height)); fi;;
  esac
  ((time_left--))
done
clear; echo "GAME OVER — Score:$score"
