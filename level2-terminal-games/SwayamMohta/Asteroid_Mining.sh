#!/bin/bash

# Game Variables
ship_health=100
fuel=50
resources=0
asteroid_field_size=10
mining_damage=10

# Function to simulate mining
mine_asteroid() {
    damage=$((RANDOM % mining_damage))
    resources=$((resources + damage))
    fuel=$((fuel - 5))
    ship_health=$((ship_health - damage))

    echo "Mining asteroid... You gained $damage resources!"
    echo "Fuel: $fuel | Resources: $resources | Ship Health: $ship_health"
}

# Random Encounter
encounter() {
    event=$((RANDOM % 3))

    if [ $event -eq 0 ]; then
        echo "You encountered a space pirate! They stole some of your resources."
        stolen=$((RANDOM % 15))
        resources=$((resources - stolen))
        echo "$stolen resources stolen!"
    elif [ $event -eq 1 ]; then
        echo "A rogue asteroid hit your ship! Damage: $((RANDOM % 20))"
        ship_health=$((ship_health - RANDOM % 20))
    fi
}

# Main Loop
while [ $ship_health -gt 0 ] && [ $fuel -gt 0 ]; do
    echo "Current Status: Ship Health: $ship_health | Fuel: $fuel | Resources: $resources"
    echo "What would you like to do?"
    echo "1. Mine an asteroid"
    echo "2. Check resources"
    echo "3. Exit game"
    read -p "Enter choice: " choice

    case $choice in
        1) 
            mine_asteroid
            encounter
            ;;
        2)
            echo "Resources: $resources, Fuel: $fuel, Ship Health: $ship_health"
            ;;
        3) 
            echo "Exiting the game."
            exit 0
            ;;
        *) 
            echo "Invalid option!"
            ;;
    esac

    if [ $resources -ge 100 ]; then
        echo "You've successfully gathered enough resources! You win!"
        break
    fi

    sleep 1
done

echo "Game Over. You ran out of health or fuel."
