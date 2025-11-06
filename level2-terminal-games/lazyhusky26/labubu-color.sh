#!/bin/bash

declare -A color_codes=(
  ["Pink"]="\033[95m"
  ["Blue"]="\033[94m"
  ["Green"]="\033[92m"
  ["Purple"]="\033[35m"
  ["Black"]="\033[30m"
  ["White"]="\033[97m"
  ["Cyan"]="\033[36m"
  ["Gold"]="\033[33m"
  ["Silver"]="\033[37m"
  ["Red"]="\033[91m"
)

reset="\033[0m"

colors=("Pink" "Blue" "Green" "Purple" "Black" "White" "Cyan" "Gold" "Silver" "Red")

echo "Welcome to the 'What Color is Your Labubu?'"
echo "-----------------------------------------------"
sleep 1

read -p "What's your name?: " name
sleep 1

echo "Let's find out what color your Labubu is..."
sleep 2

color=${colors[$RANDOM % ${#colors[@]}]}
code=${color_codes[$color]}

echo "Thinking..."
sleep 1

echo -e "Your Labubu's color is: ${code}${color}"
