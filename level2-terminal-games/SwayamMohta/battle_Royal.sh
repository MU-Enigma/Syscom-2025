#!/bin/bash

# Initialize player stats
player_health=100
player_attack=10
player_defense=5

# Initialize enemy stats
enemy_health=100
enemy_attack=10
enemy_defense=3

# Function to handle player attack
attack() {
    damage=$((RANDOM % player_attack))
    echo "You attack the enemy for $damage damage!"
    enemy_health=$((enemy_health - damage))
}

# Function to handle enemy attack
enemy_attack() {
    damage=$((RANDOM % enemy_attack))
    echo "The enemy attacks you for $damage damage!"
    player_health=$((player_health - damage))
}

# Game loop
while [ $player_health -gt 0 ] && [ $enemy_health -gt 0 ]; do
    echo "Your Health: $player_health | Enemy Health: $enemy_health"
    echo "Choose your action:"
    echo "1. Attack"
    echo "2. Defend"
    read -p "Enter choice: " choice

    case $choice in
        1) attack ;;
        2) 
            echo "You defend yourself!" 
            player_defense=$((player_defense + 2)) 
            ;;
        *) echo "Invalid choice." ;;
    esac
    
    enemy_attack
    sleep 1
done

if [ $player_health -le 0 ]; then
    echo "You have been defeated!"
else
    echo "You defeated the enemy!"
fi
