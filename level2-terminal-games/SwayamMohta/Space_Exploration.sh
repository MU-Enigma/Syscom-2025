#!/bin/bash

# Game variables
fuel=100
health=100
resources=0
location="Earth"

# Function to explore space
explore() {
    random_event=$((RANDOM % 3))
    if [ $random_event -eq 0 ]; then
        echo "You discovered a new resource! (+10 resources)"
        resources=$((resources + 10))
    elif [ $random_event -eq 1 ]; then
        echo "You encountered space pirates! (-20 health)"
        health=$((health - 20))
    else
        echo "You find nothing interesting."
    fi
    fuel=$((fuel - 10))
}

# Game loop
while [ $fuel -gt 0 ] && [ $health -gt 0 ]; do
    echo "Location: $location | Health: $health | Fuel: $fuel | Resources: $resources"
    echo "Choose an action:"
    echo "1. Explore space"
    echo "2. Refuel (cost 30 resources)"
    read -p "Enter choice: " choice
    
    case $choice in
        1) explore ;;
        2)
            if [ $resources -ge 30 ]; then
                echo "Refueling... (+50 fuel)"
                resources=$((resources - 30))
                fuel=$((fuel + 50))
            else
                echo "Not enough resources to refuel."
            fi
            ;;
        *) echo "Invalid choice." ;;
    esac

    sleep 1
done

if [ $fuel -le 0 ]; then
    echo "Out of fuel! You drifted into space."
elif [ $health -le 0 ]; then
    echo "You have died in space."
else
    echo "Congratulations! You survived the galaxy."
fi
