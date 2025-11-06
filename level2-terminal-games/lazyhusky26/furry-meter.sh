#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

clear
echo -e "${CYAN}Welcome to the Furry Meter${RESET}"
echo
echo -e "${YELLOW}Let's see how delightfully furry you are!${RESET}"
echo
read -p "Please enter your name: " name
echo

furriness=$((RANDOM % 101))

if [ $furriness -lt 20 ]; then
    message="You might just enjoy the occasional animal sticker."
elif [ $furriness -lt 50 ]; then
    message="You’ve got a hint of fursona energy."
elif [ $furriness -lt 80 ]; then
    message="Strong furry vibes detected! Fluffy energy everywhere!"
else
    message="FULL FURRY ICON!!! Your fursona would be legendary!"
fi

echo -e "${GREEN}Analyzing...${RESET}"
sleep 1
echo -e "${CYAN}--------------------------------------${RESET}"
echo -e "${YELLOW}${name}${RESET}, you are ${RED}${furriness}%${RESET} furry!"
echo -e "${CYAN}${message}${RESET}"
echo -e "${CYAN}--------------------------------------${RESET}"
echo

echo -e "${GREEN}Thanks for using the Furry Meter!${RESET}"
