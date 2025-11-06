#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

clear
echo -e "${MAGENTA}Welcome to the BETTER Relationship Meter${RESET}"
echo
echo -e "${YELLOW}Let's find out if these two are destined for greatness or just a beautiful disaster.${RESET}"
echo

read -p "Enter the first name: " name1
read -p "Enter the second name: " name2
echo

compatibility=$((RANDOM % 101))

if [ $compatibility -lt 10 ]; then
    message="A tragic pairing. The chemistry here could only power an awkward group project."
elif [ $compatibility -lt 25 ]; then
    message="This is giving 'mutual trauma bond that ends in blocked numbers.' Enter at your own risk."
elif [ $compatibility -lt 40 ]; then
    message="Barely functional. You two would argue about whose turn it is to blink."
elif [ $compatibility -lt 55 ]; then
    message="There’s potential... if we define potential as 'possible tolerance after years of therapy.'"
elif [ $compatibility -lt 70 ]; then
    message="Messy but magnetic. Everyone around you would call it toxic — and they’d be right."
elif [ $compatibility -lt 85 ]; then
    message="Dangerously compatible. You’d either fall in love or start a small cult together."
else
    message="A divine union. The kind of chemistry that could cause spontaneous combustion and neighborhood gossip."
fi

echo -e "${GREEN}Analyzing this questionable connection...${RESET}"
sleep 1
echo -e "${CYAN}--------------------------------------${RESET}"
echo -e "${YELLOW}${name1}${RESET} and ${YELLOW}${name2}${RESET} are ${RED}${compatibility}%${RESET} compatible."
echo -e "${CYAN}${message}${RESET}"
echo -e "${CYAN}--------------------------------------${RESET}"
echo
echo -e "${MAGENTA}Thanks for using the Relationship Meter: Extreme Zest Edition.${RESET}"
echo -e "${MAGENTA}Remember: love is temporary, but drama is forever.${RESET}"
