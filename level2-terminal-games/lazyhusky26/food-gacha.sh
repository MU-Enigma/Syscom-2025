#!/bin/bash

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

commons=("Apple" "Banana" "Carrot" "Bread" "Cheese")
rares=("Pizza" "Sushi" "Burger" "Pasta")
epics=("Steak" "Lobster" "Chocolate Cake")
legendaries=("Golden Truffle" "Dragonfruit" "Ambrosia" "Caviar")

pull_gacha() {
    roll=$((RANDOM % 100 + 1))
    echo "Rolling..."
    sleep 1

    if [ $roll -le 70 ]; then
        rarity="Common"
        items=("${commons[@]}")
        color=$YELLOW
    elif [ $roll -le 90 ]; then
        rarity="Rare"
        items=("${rares[@]}")
        color=$GREEN
    elif [ $roll -le 99 ]; then
        rarity="Epic"
        items=("${epics[@]}")
        color=$BLUE
    else
        rarity="Legendary"
        items=("${legendaries[@]}")
        color=$RED
    fi

    index=$((RANDOM % ${#items[@]}))
    item=${items[$index]}
    echo -e "You pulled a ${color}$rarity Food${NC}: ${color}$item${NC}"
}

echo "========================="
echo "       FOOD GACHA"
echo "========================="
echo
echo "Welcome to the Food Gacha!"
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
