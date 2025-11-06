#!/bin/bash

# Maze dimensions
width=10
height=10

# Maze structure
maze=(
    "##########"
    "#        #"
    "# ## ##  #"
    "#        #"
    "#  ## ## #"
    "#        #"
    "#  ####  #"
    "#        #"
    "#  ##  X #"
    "##########"
)

# Function to display the maze
display_maze() {
    clear
    for row in "${maze[@]}"; do
        echo "$row"
    done
}

# Initialize the player's position
player_x=1
player_y=1
maze[$player_x]="${maze[$player_x]:0:$player_y}O${maze[$player_x]:$((player_y + 1))}"  # Place player at the start

# Function to move the player
move_player() {
    maze[$player_x]="${maze[$player_x]:0:$player_y} ${maze[$player_x]:$((player_y + 1))}"  # Clear previous position
    case $1 in
        w) ((player_x--)) ;;  # Move up
        s) ((player_x++)) ;;  # Move down
        a) ((player_y--)) ;;  # Move left
        d) ((player_y++)) ;;  # Move right
    esac

    # Check if the new position is out of bounds or a wall
    if [[ ${maze[$player_x]:$player_y:1} == "#" || $player_x -lt 0 || $player_x -ge $height || $player_y -lt 0 || $player_y -ge $width ]]; then
        return 1  # Invalid move
    fi

    # Place the player at the new position
    maze[$player_x]="${maze[$player_x]:0:$player_y}O${maze[$player_x]:$((player_y + 1))}"

    # Check if player reached the exit (X)
    if [[ ${maze[$player_x]:$player_y:1} == "X" ]]; then
        return 2  # Player found the exit
    fi
    return 0  # Valid move
}

# Game loop
while true; do
    display_maze
    echo "Use W, A, S, D to move. Press Q to quit."

    read -n 1 -s key
    if [[ $key == "q" ]]; then
        echo "Exiting the game."
        break
    fi

    move_player $key
    result=$?

    if [[ $result -eq 2 ]]; then
        display_maze
        echo "Congratulations! You reached the exit!"
        break
    elif [[ $result -eq 1 ]]; then
        echo "Invalid move! Try again."
    fi
done
