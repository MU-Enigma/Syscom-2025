#!/bin/bash
# Fast single firework explosion (ends in ~4 seconds)

cols=$(tput cols)
lines=$(tput lines)
center_x=$((cols / 2))
center_y=$((lines / 2))

trap "tput cnorm; clear; exit" SIGINT
tput civis

layers=(
  "0 0"
  "-1 0" "1 0" "0 -1" "0 1"
  "-1 -1" "-1 1" "1 -1" "1 1"
  "-2 0" "2 0" "0 -2" "0 2"
  "-2 -1" "-2 1" "2 -1" "2 1" "-1 -2" "1 -2" "-1 2" "1 2"
  "-3 0" "3 0" "0 -3" "0 3"
  "-4 0" "4 0" "0 -4" "0 4" "-3 -2" "-3 2" "3 -2" "3 2"
)

color=$((31 + RANDOM % 7))

for ((frame=0; frame<${#layers[@]}; frame++)); do
  clear
  for coords in "${layers[@]:0:frame}"; do
    dx=$(echo $coords | awk '{print $1}')
    dy=$(echo $coords | awk '{print $2}')
    x=$((center_x + dx))
    y=$((center_y + dy))
    tput cup $y $x
    echo -ne "\e[1;${color}m*\e[0m"
  done
  sleep 0.05
done

# Fade out effect
for fade in {1..3}; do
  sleep 0.3
  clear
done

tput cnorm
clear
echo "🎆 Firework finished!"
