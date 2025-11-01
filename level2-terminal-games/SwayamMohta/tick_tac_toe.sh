#!/bin/bash

# Function to print the current board
print_board() {
    echo " ${board[0]} | ${board[1]} | ${board[2]} "
    echo "---|---|---"
    echo " ${board[3]} | ${board[4]} | ${board[5]} "
    echo "---|---|---"
    echo " ${board[6]} | ${board[7]} | ${board[8]} "
}

# Function to check if a player has won
check_winner() {
    # Check rows, columns, and diagonals for a win
    for i in 0 3 6; do
        if [ "${board[$i]}" == "$1" ] && [ "${board[$i+1]}" == "$1" ] && [ "${board[$i+2]}" == "$1" ]; then
            return 0
        fi
    done

    for i in 0 1 2; do
        if [ "${board[$i]}" == "$1" ] && [ "${board[$i+3]}" == "$1" ] && [ "${board[$i+6]}" == "$1" ]; then
            return 0
        fi
    done

    # Check diagonals
    if [ "${board[0]}" == "$1" ] && [ "${board[4]}" == "$1" ] && [ "${board[8]}" == "$1" ]; then
        return 0
    fi
    if [ "${board[2]}" == "$1" ] && [ "${board[4]}" == "$1" ] && [ "${board[6]}" == "$1" ]; then
        return 0
    fi

    return 1
}

# Function to check for a tie
check_tie() {
    for i in "${board[@]}"; do
        if [ "$i" != "X" ] && [ "$i" != "O" ]; then
            return 1
        fi
    done
    return 0
}

# Main game loop
board=("1" "2" "3" "4" "5" "6" "7" "8" "9")
current_player="X"

echo "Welcome to Tic-Tac-Toe!"
print_board

while true; do
    # Ask the current player to make a move
    read -p "Player $current_player, choose a position (1-9): " move

    # Validate the move
    if [[ ! "$move" =~ ^[1-9]$ ]] || [ "${board[$move-1]}" == "X" ] || [ "${board[$move-1]}" == "O" ]; then
        echo "Invalid move. Try again."
        continue
    fi

    # Update the board with the player's move
    board[$move-1]="$current_player"

    # Print the updated board
    print_board

    # Check if the current player has won
    if check_winner "$current_player"; then
        echo "Player $current_player wins!"
        break
    fi

    # Check if it's a tie
    if check_tie; then
        echo "It's a tie!"
        break
    fi

    # Switch to the other player
    if [ "$current_player" == "X" ]; then
        current_player="O"
    else
        current_player="X"
    fi
done
