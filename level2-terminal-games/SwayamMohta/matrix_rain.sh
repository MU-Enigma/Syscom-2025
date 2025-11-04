#!/bin/bash
cols=$(tput cols)

while true; do
  for ((i=0; i<$cols; i++)); do
    printf "\e[1;32m%s" "$((RANDOM % 2))"
  done
  printf "\n"
  sleep 0.05
done
