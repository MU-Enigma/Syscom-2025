#!/bin/bash

# Pet stats
hunger=5
happiness=5
health=5
age=0

# Function to display pet status
display_status() {
    clear
    echo "Pet Status:"
    echo "Hunger: $hunger/10"
    echo "Happiness: $happiness/10"
    echo "Health: $health/10"
    echo "Age: $age"
    echo ""
}

# Function to feed the pet
feed_pet() {
    if (( hunger < 10 )); then
        hunger=$((hunger+1))
        echo "You fed your pet. Hunger is now $hunger."
    else
        echo "Your pet is not hungry."
    fi
}

# Function to play with the pet
play_with_pet() {
    if (( happiness < 10 )); then
        happiness=$((happiness+1))
        echo "You played with your pet. Happiness is now $happiness."
    else
        echo "Your pet is already happy."
    fi
}

# Function to check pet health
check_health() {
    if (( hunger > 7 || happiness < 3 )); then
        health=$((health-1))
        echo "Your pet is not feeling well."
    else
        health=$((health+1))
        echo "Your pet's health is improving."
    fi
}

# Main game loop
while true; do
    display_status

    if (( health <= 0 )); then
        echo "Your pet is too sick and has run away!"
        break
    fi

    echo "Choose an action:"
    echo "1. Feed pet"
    echo "2. Play with pet"
    echo "3. Check health"
    echo "4. Quit"

    read -p "Your choice: " choice

    case $choice in
        1) feed_pet ;;
        2) play_with_pet ;;
        3) check_health ;;
        4) echo "Goodbye!"; break ;;
        *) echo "Invalid choice, try again." ;;
    esac

    # Increase age every turn
    age=$((age+1))

    # Pet gets hungrier over time
    hunger=$((hunger-1))
    if (( hunger < 0 )); then hunger=0; fi

    # Pet's happiness decreases if neglected
    happiness=$((happiness-1))
    if (( happiness < 0 )); then happiness=0; fi

    # End the game if pet is too old or sick
    if (( age > 20 )); then
        echo "Your pet has lived a full life and passed away. Game over."
        break
    fi

    sleep 2
done
