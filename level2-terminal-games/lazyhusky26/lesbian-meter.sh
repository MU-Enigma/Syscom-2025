#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

clear
echo -e "${MAGENTA}Welcome to the LESBIAN METER${RESET}"
echo
echo -e "${YELLOW}Let's find out how powerfully lesbian you are today!${RESET}"
echo
read -p "Please enter your name: " name
echo

lesbian_power=$((RANDOM % 101))

if [ $lesbian_power -lt 20 ]; then
    message="You might still be figuring things out — but you definitely appreciate a good flannel."
elif [ $lesbian_power -lt 50 ]; then
    message="You’ve definitely had a crush on your best friend once."
elif [ $lesbian_power -lt 80 ]; then
    message="You radiate sapphic energy — the cottagecore gods smile upon you."
else
    message="ABSOLUTE LESBIAN LEGEND. The gay agenda salutes you!"
fi

echo -e "${GREEN}Analyzing sapphic vibes...${RESET}"
sleep 1
echo -e "${CYAN}--------------------------------------${RESET}"
echo -e "${YELLOW}${name}${RESET}, your lesbian power level is ${RED}${lesbian_power}%${RESET}."
echo -e "${CYAN}${message}${RESET}"
echo -e "${CYAN}--------------------------------------${RESET}"
echo
echo -e "${MAGENTA}Thanks for using the Lesbian Meter! Stay radiant and keep loving who you love.${RESET}"
