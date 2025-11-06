#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

clear
echo -e "${MAGENTA}Welcome to the Friendship Meter${RESET}"
echo
echo -e "${YELLOW}Let's see how strong the friendship bond is!${RESET}"
echo

read -p "Enter the first friend's name: " name1
read -p "Enter the second friend's name: " name2
echo

friendship=$((RANDOM % 101))

if [ $friendship -lt 20 ]; then
    message="You barely know each other."
elif [ $friendship -lt 40 ]; then
    message="Acquaintances at best."
elif [ $friendship -lt 60 ]; then
    message="Friendly, but room to grow."
elif [ $friendship -lt 80 ]; then
    message="Good friends."
else
    message="Besties for life!"
fi

echo -e "${GREEN}Checking the friendship vibes...${RESET}"
sleep 1
echo -e "${CYAN}--------------------------------------${RESET}"
echo -e "${YELLOW}${name1}${RESET} and ${YELLOW}${name2}${RESET} have ${RED}${friendship}%${RESET} friendship."
echo -e "${CYAN}${message}${RESET}"
echo -e "${CYAN}--------------------------------------${RESET}"
echo
echo -e "${MAGENTA}Thanks for using the Friendship Meter!${RESET}"
