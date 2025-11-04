#!/bin/bash

# Initial stats
health=100
hunger=50
energy=50
resources=0
shelter=false
weather="clear"

# Game Functions
gather_resources() {
    echo "You gather resources..."
    resources=$((resources + 10))
    energy=$((energy - 10))
    echo "Resources: $resources | Energy: $energy"
}

build_shelter() {
    if [ $resources -ge 20 ]; then
        shelter=true
        resources=$((resources - 20))
        echo "You build a shelter to protect yourself from the storm."
    else
        echo "Not enough resources to build a shelter."
    fi
}

check_weather() {
    weather_options=("clear" "storm" "cold" "heatwave")
    weather=${weather_options[$RANDOM % ${#weather_options[@]}]}
    echo "The weather is $weather."
}

random_event() {
    event=$((RANDOM % 2))
    if [ $event -eq 0 ]; then
        echo "A wild animal attacked! You lose 20 health."
        health=$((health - 20))
    else
        echo "A supply drop arrived! You gain 10 resources."
        resources=$((resources + 10))
    fi
}

# Game Loop
while [ $health -gt 0 ] && [ $energy -gt 0 ] && [ $hunger -gt 0 ]; do
    echo "Health: $health | Hunger: $hunger | Energy: $energy | Resources: $resources"
    echo "1. Gather Resources"
    echo "2. Build Shelter"
    echo "3. Rest"
    echo "4. Exit Game"
    read -p "Choose action: " action

    case $action in
        1)
            gather_resources
            check_weather
            random_event
            ;;
        2)
            build_shelter
            ;;
        3)
            energy=$((energy + 20))
            hunger=$((hunger - 10))
            echo "You rest and recover some energy."
            ;;
        4)
            echo "Exiting game."
            break
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac

    # Simulate hunger and energy depletion
    hunger=$((hunger - 5))
    energy=$((energy - 5))

    if [ $hunger -le 0 ]; then
        echo "You starved to death."
        break
    fi

    if [ $energy -le 0 ]; then
        echo "You collapsed from exhaustion."
        break
    fi
done
