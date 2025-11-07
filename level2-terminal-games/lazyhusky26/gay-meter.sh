#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

clear
echo -e "${CYAN}Welcome to the BETTER Gay Meter${RESET}"
echo
echo -e "${YELLOW}Let's find out just how fabulously gay you are!${RESET}"
echo
read -p "Please enter your name: " name
echo

gayness=$((RANDOM % 101))

if [ $gayness -lt 20 ]; then
    message="You’re basically straight... but you'd never know what the future holds!"
elif [ $gayness -lt 50 ]; then
    message="You might swing both ways"
elif [ $gayness -lt 80 ]; then
    message="You’re serving some serious queer energy"
else
    message="FULL GAY ICON!!!! Beyoncé would be proud!"
fi

echo -e "${GREEN}Analyzing...${RESET}"
sleep 1
echo -e "${CYAN}--------------------------------------${RESET}"
echo -e "${YELLOW}${name}${RESET}, you are ${RED}${gayness}%${RESET} gay!"
echo -e "${CYAN}${message}${RESET}"
echo -e "${CYAN}--------------------------------------${RESET}"
echo

echo -e "${GREEN}Thanks for using the Gay Meter! Stay fabulous!${RESET}"
