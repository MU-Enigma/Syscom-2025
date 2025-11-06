#!/bin/bash

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

commons=("Robin" "Batgirl" "Cyborg" "Green Lantern (John Stewart)" "Flash (Wally West)")
rares=("Wonder Woman" "Aquaman" "Green Lantern (Hal Jordan)" "The Flash (Barry Allen)")
epics=("Batman" "Superman" "Martian Manhunter")
legendaries=("Darkseid" "Joker" "Lex Luthor" "Brainiac")

pull_gacha() {
    roll=$((RANDOM % 100 + 1))
    echo "Rolling..."
    sleep 1

    if [ $roll -le 70 ]; then
        rarity="Common"
        chars=("${commons[@]}")
        color=$YELLOW
    elif [ $roll -le 90 ]; then
        rarity="Rare"
        chars=("${rares[@]}")
        color=$GREEN
    elif [ $roll -le 99 ]; then
        rarity="Epic"
        chars=("${epics[@]}")
        color=$BLUE
    else
        rarity="Legendary"
        chars=("${legendaries[@]}")
        color=$RED
    fi

    index=$((RANDOM % ${#chars[@]}))
    char=${chars[$index]}
    echo -e "You pulled a ${color}$rarity DC Character${NC}: ${color}$char${NC}"
}

echo "========================="
echo "        DC GACHA"
echo "========================="
echo
echo "Welcome to the DC Gacha!"
echo "Each pull costs 1 ticket."
echo

tickets=10

while [ $tickets -gt 0 ]; do
    echo "You have $tickets tickets left."
    read -p "Press ENTER to pull or type 'q' to exit: " choice
    if [[ $choice == "q" ]]; then
        echo "Thanks for playing!"
        break
    fi

    ((tickets--))
    pull_gacha
    echo
done

if [ $tickets -eq 0 ]; then
    echo "You're out of tickets :("
    echo "Come back later..."
fi
