#!/bin/bash
# HACKER TYPER SIMULATOR

clear
echo "HACKER TYPER SIMULATOR"
echo "Type fast to finish 'hacking' before time runs out!"
sleep 2

progress=0
goal=100
time_left=15

while (( time_left > 0 && progress < goal )); do
  clear
  echo "Time Left: $time_left sec | Progress: $progress%"
  echo "Keep typing..."
  read -rsn1 -t1 key
  if [[ $key != "" ]]; then
    rand_code=$(cat /dev/urandom | tr -dc 'A-Za-z0-9;:{}()[]' | head -c 20)
    echo "$rand_code"
    ((progress+=5))
  fi
  ((time_left--))
done

clear
if (( progress >= goal )); then
  echo "ACCESS GRANTED"
else
  echo "SYSTEM LOCKED — YOU FAILED!"
fi
