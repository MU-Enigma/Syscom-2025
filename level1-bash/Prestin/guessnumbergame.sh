#!/bin/bash
S=$((RANDOM % 100 + 1))
T=0
echo "Guess a number 1-100."
while read -rp "> " G; do
  ((T++))
  if [ "$G" -lt "$S" ]; then echo "Low!"; 
  elif [ "$G" -gt "$S" ]; then echo "High!";
  else echo "You got $S in $T tries!" && break; fi
done