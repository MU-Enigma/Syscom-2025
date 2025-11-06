#!/bin/bash

# Game Variables
health=100
resources=50
tower_cost=20
meteor_count=10
wave=1

# Function to show game status
show_status() {
    echo "Earth Health: $health | Resources: $resources | Meteors: $meteor_count"
}

# Function to spawn meteors
spawn_meteors() {
    meteors_in_wave=$((RANDOM % 5 + 1))
    meteor_count=$((meteor_count + meteors_in_wave))
    echo "Wave $wave incoming! $meteors_in_wave meteors approaching!"
}

# Function to build tower
build_tower() {
    if [ $resources -ge $tower_cost ]; then
        resources=$((resources - tower_cost))
        echo "You build a tower to destroy meteors."
    else
        echo "Not enough resources to build a tower!"
    fi
}

# Function to handle meteor attack
meteor_attack() {
    if [ $meteor_count -gt 0 ]; then
        meteor_damage=$((RANDOM % 20 + 5))
        health=$((health - meteor_damage))
        meteor_count=$((meteor_count - 1))
        echo "A meteor hits Earth and causes $meteor_damage damage!"
    else
        echo "No meteors this round."
    fi
}

# Main Game Loop
echo "Welcome to Meteor Defense!"

while [ $health -gt 0 ]; do
    show_status
    echo "1. Build a tower"
    echo "2. Wait for meteors"
    echo "3. Exit Game"
    read -p "Choose action: " action

    case $action in
        1)
            build_tower
            ;;
        2)
            meteor_attack
            spawn_meteors
            wave=$((wave + 1))
            ;;
        3)
            echo "Exiting game."
            break
            ;;
        *)
            echo "Invalid choice!"
            ;;
    esac

    # Check for Game Over conditions
    if [ $health -le 0 ]; then
        echo "Earth has been destroyed by meteors!"
        break
    fi

    sleep 1
done
