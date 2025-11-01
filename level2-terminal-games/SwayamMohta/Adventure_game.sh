#!/bin/bash

# Welcome message
echo "Welcome to the Dungeon Adventure Game!"
echo "You are standing in front of a dark dungeon entrance."

# First choice
echo "Do you want to enter the dungeon? (yes/no)"
read -r choice

if [[ "$choice" == "yes" ]]; then
    # Enter the dungeon
    echo "You walk into the dark dungeon. It's damp and cold."
    echo "Do you want to go left or right? (left/right)"
    read -r direction

    if [[ "$direction" == "left" ]]; then
        echo "You find a treasure chest! You've won the game!"
    elif [[ "$direction" == "right" ]]; then
        echo "You encounter a wild monster! Game Over!"
    else
        echo "Invalid choice! The dungeon is too dark to continue."
    fi
else
    # Don't enter the dungeon
    echo "You decide not to enter the dungeon and walk away. The end."
fi
