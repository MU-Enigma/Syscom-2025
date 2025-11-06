#!/bin/bash

# Game Variables
health=100
battery=100
inventory=()
monster_encounter=false

# Functions
explore_room() {
    echo "You enter a dark room. You need to use a flashlight."
    if [ $battery -le 0 ]; then
        echo "Your flashlight is out of battery!"
        health=$((health - 10))
    else
        battery=$((battery - 10))
        echo "You use the flashlight, but feel like you're being watched."
    fi

    monster_encounter=$((RANDOM % 2))
    if [ $monster_encounter -eq 1 ]; then
        echo "A monster appears! You fight back."
        health=$((health - 30))
    fi
}

use_item() {
    if [[ " ${inventory[@]} " =~ " first_aid " ]]; then
        echo "You use a first aid kit to restore 50 health."
        health=$((health + 50))
        inventory=("${inventory[@]/first_aid/}")
    else
        echo "You have no healing items."
    fi
}

# Main Game Loop
while [ $health -gt 0 ] && [ $battery -gt 0 ]; do
    echo "Health: $health | Battery: $battery | Inventory: ${inventory[@]}"
    echo "1. Explore Room"
    echo "2. Use Item (if available)"
    echo "3. Exit Game"
    read -p "Choose action: " action

    case $action in
        1) 
            explore_room
            ;;
        2)
            use_item
            ;;
        3)
            echo "Exiting game."
            exit 0
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac

    # Random events
    if [ $((RANDOM % 3)) -eq 0 ]; then
        inventory+=("first_aid")
        echo "You find a first aid kit."
    fi

    if [ $health -le 0 ]; then
        echo "You have been killed by the monster."
        break
    fi

    sleep 1
done
