#!/bin/bash

echo "Lets play Russian Roulette"
echo "There are 6 chambers. One is loaded, the other 5 are safe. Best of luck!, lets try not to get shot"
echo " "

bullet=$(( RANDOM % 6 + 1 ))

while true; do
    echo -n "Press Enter to pull the trigger (or type q to quit): "
    read input
    if [[ $input == "q" ]]; then
        echo "You decided to walk away. Smart choice."
        exit 0
    fi

    # Randomly select a chamber
    chamber=$(( RANDOM % 6 + 1 ))

    echo "Spinning the cylinder..."
    sleep 1
    echo "Pulling the trigger..."
    sleep 1

    if [[ $chamber -eq $bullet ]]; then
        echo "BANG! You're out. Game over!"
        exit 0
    else
        echo "Click. You're safe... for now."
        echo ""
    fi
done
