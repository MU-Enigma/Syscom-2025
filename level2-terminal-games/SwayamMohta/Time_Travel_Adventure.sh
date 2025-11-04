#!/bin/bash

# Game Variables
current_time="Present"
health=100
inventory=()

# Time Travel Options
time_periods=("Past" "Present" "Future")
past_event="Ancient Artifact"
future_event="AI Overlords"

# Time Travel function
time_travel() {
    echo "You traveled to the $current_time!"

    if [ "$current_time" == "Past" ]; then
        echo "You find an ancient artifact. Do you take it? (y/n)"
        read -p "Enter choice: " choice
        if [ "$choice" == "y" ]; then
            inventory+=("$past_event")
            echo "You take the artifact!"
        fi
    elif [ "$current_time" == "Future" ]; then
        echo "You encounter AI Overlords. Do you fight? (y/n)"
        read -p "Enter choice: " choice
        if [ "$choice" == "y" ]; then
            health=$((health - 20))
            echo "You fought the overlords but lost some health!"
        fi
    fi

    echo "Health: $health | Inventory: ${inventory[@]}"
}

# Main Game Loop
while [ $health -gt 0 ]; do
    echo "Current time: $current_time | Health: $health"
    echo "What would you like to do?"
    echo "1. Time Travel"
    echo "2. Check Inventory"
    echo "3. Exit Game"
    read -p "Enter choice: " action

    case $action in
        1)
            current_time=${time_periods[$RANDOM % ${#time_periods[@]}]}
            time_travel
            ;;
        2)
            echo "Inventory: ${inventory[@]}"
            ;;
        3)
            echo "Exiting game."
            exit 0
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac

    sleep 1
done

echo "Game Over! You've run out of health."
