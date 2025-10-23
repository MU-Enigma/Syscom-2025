#!/bin/bash

commons=("Slime" "Goblin" "Bat" "Rat" "Wolf")
rares=("Knight" "Archer" "Mage" "Healer")
epics=("Dragon" "Assassin" "Warlock")
legendaries=("Phoenix" "Demon Lord" "Celestial Hero" "Dilip")

pull_gacha() {
    roll=$((RANDOM % 100 + 1))
    echo "Rolling..."
    sleep 1

    if [ $roll -le 70 ]; then
        rarity="Common"
        chars=("${commons[@]}")
    elif [ $roll -le 90 ]; then
        rarity="Rare"
        chars=("${rares[@]}")
    elif [ $roll -le 99 ]; then
        rarity="Epic"
        chars=("${epics[@]}")
    else
        rarity="Legendary"
        chars=("${legendaries[@]}")
    fi

    index=$((RANDOM % ${#chars[@]}))
    char=${chars[$index]}
    echo "You pulled a $rarity: $char"
}

echo "========================="
echo "     GACHA SIMULATOR"
echo "========================="
echo
echo "Welcome"
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
