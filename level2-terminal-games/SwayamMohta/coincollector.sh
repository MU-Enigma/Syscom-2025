#!/bin/bash
# COIN COLLECTOR
width=10; height=6; px=5; py=3; coins=0; secs=20
cx=$((RANDOM%width)); cy=$((RANDOM%height))
stty -echo -icanon time 0 min 0; trap "stty echo icanon; clear; exit" INT
while ((secs>0)); do
  clear; echo "Coins:$coins | Time:$secs"
  for ((y=0;y<height;y++)); do
    for ((x=0;x<width;x++)); do
      if ((x==px&&y==py)); then printf "@"
      elif ((x==cx&&y==cy)); then printf "$"
      else printf "."
      fi
    done; echo
  done
  read -rsn1 -t0.2 key
  case $key in
    w)((py>0))&&((py--));;
    s)((py<height-1))&&((py++));;
    a)((px>0))&&((px--));;
    d)((px<width-1))&&((px++));;
  esac
  if ((px==cx&&py==cy)); then ((coins++)); cx=$((RANDOM%width)); cy=$((RANDOM%height)); fi
  ((secs--))
done
clear; echo "GAME OVER — Coins:$coins"
