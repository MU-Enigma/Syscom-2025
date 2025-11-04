#!/bin/bash

# Initialize Maze
declare -A maze
width=10
height=10
player_x=0
player_y=0
teleport_keys=0

# Function to generate a random maze
generate_maze() {
    for ((i=0; i<$width; i++)); do
        for ((j=0; j<$height; j++)); do
            maze[$i,$j]=0
        done
    done

    maze[$((RANDOM % width)),$((RANDOM % height))]=2  # Teleport Key
    maze[$((RANDOM % width)),$((RANDOM % height))]=3  # Teleport Point
}

# Function to display the maze
draw_maze() {
    clear
    for ((i=0; i<$width; i++)); do
        row=""
        for ((j=0; j<$height; j++)); do
            if [ $i -eq $player_x ] && [ $j -eq $player_y ]; then
                row="$row P"
            elif [ ${maze[$i,$j]} -eq 1 ]; then
                row="$row #"
            elif [ ${maze[$i,$j]} -eq 2 ]; then
                row="$row K"  # Quantum Key
            elif [ ${maze[$i,$j]} -eq 3 ]; then
                row="$row T"  # Teleportation point
            else
                row="$row ."
            fi
        done
        echo "$row"
    done
}

# Movement and interaction
move() {
    case $1 in
        w) [ $player_x -gt 0 ] && player_x=$((player_x-1)) ;;
        s) [ $player_x -lt $((width-1)) ] && player_x=$((player_x+1)) ;;
        a) [ $player_y -gt 0 ] && player_y=$((player_y-1)) ;;
        d) [ $player_y -lt $((height-1)) ] && player_y=$((player_y+1)) ;;
        *)
            echo "Invalid move!"
            return
            ;;
    esac

    # Check for teleportation or key
    if [ ${maze[$player_x,$player_y]} -eq 2 ]; then
        echo "You found a quantum key!"
        teleport_keys=$((teleport_keys + 1))
    elif [ ${maze[$player_x,$player_y]} -eq 3 ] && [ $teleport_keys -gt 0 ]; then
        echo "You use a quantum key to teleport!"
        player_x=$((RANDOM % width))
        player_y=$((RANDOM % height))
    fi
}

# Main loop
generate_maze

while true; do
    draw_maze
    echo "Teleport Keys: $teleport_keys"
    echo "What would you like to do? (WASD to move, Q to quit)"
    read -n 1 -s move_choice
    if [ "$move_choice" == "q" ]; then
        echo "Exiting game."
        break
    fi
    move $move_choice
    sleep 1
done
