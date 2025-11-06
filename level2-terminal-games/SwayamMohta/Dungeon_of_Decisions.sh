#!/bin/bash

# Character stats
health=100
strength=10
moral_alignment=0  # -100 (evil) to 100 (good)

# Story function
start_adventure() {
    echo "You enter the Dungeon of Decisions..."
    echo "Your goal: Find the legendary treasure. But beware, the dungeon is full of traps and moral dilemmas."
}

first_decision() {
    echo "You reach a fork in the path. Do you go left into the dark cave, or right into the bright hall?"
    echo "1. Enter the dark cave"
    echo "2. Enter the bright hall"
    read -p "Choose action: " choice

    case $choice in
        1)
            echo "You enter the cave and find a treasure chest. A trap is triggered!"
            health=$((health - 20))
            moral_alignment=$((moral_alignment - 10))
            echo "You lose 20 health and your moral alignment shifts towards evil."
            ;;
        2)
            echo "You enter the hall and meet an NPC in need of help. Do you help them?"
            echo "1. Help the NPC"
            echo "2. Ignore the NPC"
            read -p "Choose action: " choice

            case $choice in
                1)
                    echo "You help the NPC and they give you a healing potion."
                    health=$((health + 30))
                    moral_alignment=$((moral_alignment + 20))
                    ;;
                2)
                    echo "You ignore the NPC and they curse you. You lose 10 health."
                    health=$((health - 10))
                    moral_alignment=$((moral_alignment - 20))
                    ;;
                *)
                    echo "Invalid choice."
                    ;;
            esac
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac
}

# Game Loop
start_adventure
while [ $health -gt 0 ] && [ $moral_alignment -ge -100 ]; do
    first_decision
    echo "Health: $health | Moral Alignment: $moral_alignment"
    if [ $health -le 0 ]; then
        echo "You have died from injuries."
        break
    fi
    if [ $moral_alignment -le -100 ]; then
        echo "Your evil deeds have led to your downfall."
        break
    fi
done
