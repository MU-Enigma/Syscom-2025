#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

clear
echo -e "${CYAN}Welcome to the BETTER Luck Meter${RESET}"
echo
echo -e "${YELLOW}Let's see how lucky you are today!${RESET}"
echo
read -p "Please enter your name: " name
echo

luck=$((RANDOM % 101))

if [ $luck -lt 20 ]; then
    message="Yikes... might want to avoid any major life decisions today."
elif [ $luck -lt 50 ]; then
    message="Mediocre luck. Things could go either way, so maybe bring a backup plan."
elif [ $luck -lt 80 ]; then
    message="Pretty lucky! You might find money on the street or get an unexpected compliment."
else
    message="Incredible luck! The universe is definitely on your side today."
fi

echo -e "${GREEN}Calculating your luck level...${RESET}"
sleep 1
echo -e "${CYAN}--------------------------------------${RESET}"
echo -e "${YELLOW}${name}${RESET}, your luck level is ${RED}${luck}%${RESET}."
echo -e "${CYAN}${message}${RESET}"
echo -e "${CYAN}--------------------------------------${RESET}"
echo
echo -e "${GREEN}Thanks for using the Luck Meter! May fortune favor you today.${RESET}"
