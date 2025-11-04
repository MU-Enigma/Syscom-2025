#!/bin/bash

# Game Variables
ship_health=100
crew_morale=100
cannonballs=20
enemy_health=100
treasure_found=false

# Function to check ship status
check_status() {
    echo "Your ship health: $ship_health | Crew morale: $crew_morale | Cannonballs: $cannonballs"
}

# Function for combat
combat() {
    echo "A hostile pirate ship approaches!"
    while [ $ship_health -gt 0 ] && [ $enemy_health -gt 0 ]; do
        echo "1. Fire cannons"
        echo "2. Repair the ship"
        echo "3. Flee"
        read -p "Choose action: " action

        case $action in
            1) # Fire cannons
                if [ $cannonballs -gt 0 ]; then
                    cannonballs=$((cannonballs - 1))
                    damage=$((RANDOM % 30))
                    enemy_health=$((enemy_health - damage))
                    echo "You fired your cannons! You dealt $damage damage."
                else
                    echo "Out of cannonballs! You need to restock."
                fi
                ;;
            2) # Repair ship
                repair=$((RANDOM % 20))
                ship_health=$((ship_health + repair))
                crew_morale=$((crew_morale - 10))
                echo "You repaired your ship for $repair health, but crew morale drops."
                ;;
            3) # Flee
                echo "You attempt to flee, but the enemy chases you!"
                ship_health=$((ship_health - 10))
                ;;
            *)
                echo "Invalid action!"
                ;;
        esac

        # Enemy counterattack
        enemy_attack=$((RANDOM % 30))
        ship_health=$((ship_health - enemy_attack))
        echo "The enemy ship attacks! You take $enemy_attack damage."

        check_status

        if [ $ship_health -le 0 ]; then
            echo "Your ship has sunk!"
            break
        fi
        if [ $enemy_health -le 0 ]; then
            echo "You've defeated the enemy pirate ship!"
            treasure_found=true
            break
        fi
    done
}

# Main Game Loop
echo "Welcome to Pirate Ship Battle!"

while [ $ship_health -gt 0 ]; do
    echo "What would you like to do?"
    echo "1. Go on a treasure hunt"
    echo "2. Engage enemy ship"
    echo "3. Rest and recruit crew"
    echo "4. Exit game"

    read -p "Choose action: " choice

    case $choice in
        1)
            if [ $treasure_found == false ]; then
                echo "You sail to an island and find hidden treasure!"
                treasure_found=true
            else
                echo "You already found the treasure!"
            fi
            ;;
        2)
            combat
            ;;
        3)
            crew_morale=$((crew_morale + 20))
            echo "The crew rests and morale improves."
            ;;
        4)
            echo "Exiting the game."
            break
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac

    if [ $crew_morale -le 0 ]; then
        echo "Your crew has mutinied!"
        break
    fi

    if [ $ship_health -le 0 ]; then
        echo "Your ship has been destroyed!"
        break
    fi

    sleep 1
done
