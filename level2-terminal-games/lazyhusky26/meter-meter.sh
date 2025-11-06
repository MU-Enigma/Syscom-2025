#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

clear
echo -e "${CYAN}Welcome to the Meter-Idea Meter${RESET}"
echo
read -p "Enter your meter idea: " idea
echo

rating=$((RANDOM % 101))

if [ $rating -lt 20 ]; then
    message="Hmm… maybe stick to something else instead."
elif [ $rating -lt 40 ]; then
    message="It’s… something."
elif [ $rating -lt 60 ]; then
    message="Not bad! People might actually use it."
elif [ $rating -lt 80 ]; then
    message="Pretty solid! This meter idea has potential."
else
    message="PEAK!!!"
fi

echo -e "${GREEN}Evaluating your creative brilliance...${RESET}"
sleep 1
echo -e "${CYAN}--------------------------------------${RESET}"
echo -e "Your meter idea: ${YELLOW}${idea}${RESET}"
echo -e "Rating: ${RED}${rating}%${RESET} awesome"
echo -e "${CYAN}${message}${RESET}"
echo -e "${CYAN}--------------------------------------${RESET}"
