#!/bin/bash

# Battleship Game - Terminal Edition
# Usage: ./battleship.sh [--easy] [--no-color]

set -eo pipefail

# Configuration
BOARD_SIZE=5
USE_COLOR=true
DIFFICULTY="normal"

# Parse arguments
for arg in "$@"; do
    case $arg in
        --easy) DIFFICULTY="easy" ;;
        --no-color) USE_COLOR=false ;;
        *) echo "Unknown option: $arg"; exit 1 ;;
    esac
done

# Color codes
if $USE_COLOR; then
    COLOR_HIT="\033[32m"    # Green
    COLOR_MISS="\033[34m"   # Blue
    COLOR_RESET="\033[0m"
    COLOR_TITLE="\033[1;36m"
    COLOR_INFO="\033[33m"
else
    COLOR_HIT=""
    COLOR_MISS=""
    COLOR_RESET=""
    COLOR_TITLE=""
    COLOR_INFO=""
fi

# Game state arrays
declare -A board          # Hidden ship positions
declare -A display_board  # What player sees
declare -A shots_taken    # Track duplicate shots
declare -A ship_cells     # Track which ship is at each cell

# Ship definitions
declare -A ships=(
    ["Destroyer"]=2
    ["Submarine"]=3
    ["Battleship"]=4
)
declare -A ship_hits

# Game stats
total_shots=0
total_hits=0
total_misses=0

# Initialize ship hits counter
for ship in "${!ships[@]}"; do
    ship_hits[$ship]=0
done

# Initialize boards
init_board() {
    for row in {1..5}; do
        for col in A B C D E; do
            local key="${col}${row}"
            board["$key"]=0
            display_board["$key"]="."
            shots_taken["$key"]=0
        done
    done
}

# Check if ship can be placed at position
can_place_ship() {
    local start_col=$1
    local start_row=$2
    local size=$3
    local horizontal=$4
    
    for ((i=0; i<size; i++)); do
        if [ "$horizontal" -eq 1 ]; then
            local col_num=$((start_col + i))
            [ $col_num -gt $BOARD_SIZE ] && return 1
            local col=$(printf "\\$(printf '%03o' $((col_num + 64)))")
            local key="${col}${start_row}"
        else
            local row=$((start_row + i))
            [ $row -gt $BOARD_SIZE ] && return 1
            local col=$(printf "\\$(printf '%03o' $((start_col + 64)))")
            local key="${col}${row}"
        fi
        [ "${board[$key]}" -eq 1 ] && return 1
    done
    return 0
}

# Place ship on board
place_ship() {
    local ship_name=$1
    local size=$2
    
    while true; do
        local start_col=$((RANDOM % BOARD_SIZE + 1))
        local start_row=$((RANDOM % BOARD_SIZE + 1))
        local horizontal=$((RANDOM % 2))
        
        if can_place_ship $start_col $start_row $size $horizontal; then
            for ((i=0; i<size; i++)); do
                if [ $horizontal -eq 1 ]; then
                    local col_num=$((start_col + i))
                    local col=$(printf "\\$(printf '%03o' $((col_num + 64)))")
                    local key="${col}${start_row}"
                else
                    local row=$((start_row + i))
                    local col=$(printf "\\$(printf '%03o' $((start_col + 64)))")
                    local key="${col}${row}"
                fi
                board["$key"]=1
                ship_cells["$key"]=$ship_name
            done
            break
        fi
    done
}

# Display the board
display_game_board() {
    echo -e "\n${COLOR_TITLE}=== BATTLESHIP ===${COLOR_RESET}"
    echo "   A B C D E"
    for row in {1..5}; do
        printf "%d  " $row
        for col in A B C D E; do
            local key="${col}${row}"
            local cell="${display_board[$key]}"
            
            if [ "$cell" = "X" ]; then
                echo -ne "${COLOR_HIT}${cell}${COLOR_RESET} "
            elif [ "$cell" = "o" ]; then
                echo -ne "${COLOR_MISS}${cell}${COLOR_RESET} "
            else
                echo -n "${cell} "
            fi
        done
        echo
    done
    echo
}

# Display game stats
display_stats() {
    echo -e "${COLOR_INFO}Shots: $total_shots | Hits: $total_hits | Misses: $total_misses${COLOR_RESET}"
    
    if [ "$DIFFICULTY" = "easy" ]; then
        echo -e "${COLOR_INFO}Ships remaining:${COLOR_RESET}"
        for ship in "${!ships[@]}"; do
            local size=${ships[$ship]}
            local hits=${ship_hits[$ship]}
            local remaining=$((size - hits))
            if [ $remaining -gt 0 ]; then
                echo "  $ship: $remaining cells left"
            fi
        done
    fi
    echo
}

# Validate coordinate input
validate_input() {
    local input=$(echo "$1" | tr '[:lower:]' '[:upper:]' | tr -d ' ')
    
    # Check format (letter + digit)
    if ! [[ $input =~ ^[A-E][1-5]$ ]]; then
        return 1
    fi
    
    # Check if already shot
    if [ "${shots_taken[$input]}" -eq 1 ]; then
        echo "You already fired at $input!"
        return 1
    fi
    
    return 0
}

# Process shot
fire_shot() {
    local coord=$1
    shots_taken["$coord"]=1
    total_shots=$((total_shots + 1))
    
    if [ "${board[$coord]:-0}" -eq 1 ]; then
        # Hit!
        display_board["$coord"]="X"
        total_hits=$((total_hits + 1))
        
        local ship_name="${ship_cells[$coord]:-unknown}"
        local current_hits=${ship_hits[$ship_name]:-0}
        ship_hits[$ship_name]=$((current_hits + 1))
        
        echo -e "${COLOR_HIT}HIT!${COLOR_RESET}"
        
        # Check if ship is sunk
        if [ "${ship_hits[$ship_name]}" -eq "${ships[$ship_name]}" ]; then
            echo -e "${COLOR_HIT}You sunk the $ship_name!${COLOR_RESET}"
        fi
    else
        # Miss
        display_board["$coord"]="o"
        total_misses=$((total_misses + 1))
        echo -e "${COLOR_MISS}Miss.${COLOR_RESET}"
    fi
}

# Check win condition
check_win() {
    for ship in "${!ships[@]}"; do
        if [ "${ship_hits[$ship]}" -ne "${ships[$ship]}" ]; then
            return 1
        fi
    done
    return 0
}

# Main game loop
main() {
    echo -e "${COLOR_TITLE}"
    echo "╔════════════════════════════════════╗"
    echo "║      BATTLESHIP - Terminal         ║"
    echo "╚════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    
    if [ "$DIFFICULTY" = "easy" ]; then
        echo "Difficulty: EASY (hints enabled)"
    fi
    
    # Initialize
    init_board
    
    # Place ships
    for ship in "${!ships[@]}"; do
        place_ship "$ship" "${ships[$ship]}"
    done
    
    echo "Ships placed! Start firing by entering coordinates (e.g., B3)"
    echo "Board: 5×5 grid (A-E, 1-5)"
    echo
    
    # Game loop
    while true; do
        display_game_board
        display_stats
        
        # Get input
        read -p "Enter coordinates to fire: " input
        input=$(echo "$input" | tr '[:lower:]' '[:upper:]' | tr -d ' ')
        
        # Validate
        if ! validate_input "$input"; then
            [ -z "$input" ] && echo "Invalid input. Use format like B3"
            continue
        fi
        
        # Fire shot
        fire_shot "$input"
        
        # Check win
        if check_win; then
            display_game_board
            echo -e "${COLOR_TITLE}╔════════════════════════════════════╗${COLOR_RESET}"
            echo -e "${COLOR_TITLE}║         VICTORY!                   ║${COLOR_RESET}"
            echo -e "${COLOR_TITLE}╚════════════════════════════════════╝${COLOR_RESET}"
            echo
            echo "All ships destroyed!"
            echo "Total shots: $total_shots"
            echo "Hits: $total_hits"
            echo "Misses: $total_misses"
            local accuracy=$(awk "BEGIN {printf \"%.1f\", ($total_hits/$total_shots)*100}")
            echo "Accuracy: ${accuracy}%"
            break
        fi
        
        echo
    done
}

# Run the game
main