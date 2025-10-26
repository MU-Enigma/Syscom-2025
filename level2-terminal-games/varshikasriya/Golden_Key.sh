#!/bin/bash

# The grid size is 5x5, with coordinates ranging from 0 to 4.
MAX_X=4
MAX_Y=4

PLAYER_X=0      # Player's current X coordinate
PLAYER_Y=0      # Player's current Y coordinate
KEY_X=0         # Key's hidden X coordinate
KEY_Y=0         # Key's hidden Y coordinate
MOVES=0         # Count of player movements


RED='\033[0;31m'    # For moving away or errors (Hot)
YELLOW='\033[1;33m' # For mid-range or warnings (Warm)
GREEN='\033[0;32m'  # For moving closer or success (Found Key)
NC='\033[0m'        # No Color (Default/Cold)


initialize_game() {
    # Find a random unique starting location for the player and the key
    while [ "$PLAYER_X" -eq "$KEY_X" ] && [ "$PLAYER_Y" -eq "$KEY_Y" ]; do
        PLAYER_X=$(( $RANDOM % (MAX_X + 1) ))
        PLAYER_Y=$(( $RANDOM % (MAX_Y + 1) ))
        KEY_X=$(( $RANDOM % (MAX_X + 1) ))
        KEY_Y=$(( $RANDOM % (MAX_Y + 1) ))
    done
    MOVES=0
}

# Calculates the distance in steps (not diagonally) between the player and the key.
get_distance() {
    local dx=$(( PLAYER_X - KEY_X ))
    local dy=$(( PLAYER_Y - KEY_Y ))
    
    dx=$(( dx < 0 ? dx * -1 : dx ))
    dy=$(( dy < 0 ? dy * -1 : dy ))
    
    echo $(( dx + dy ))
}



get_thermal_hint() {
    local dist=$(get_distance)
    local hint_color=$NC
    local hint_text="Neutral"

    if [ $dist -eq 0 ]; then
        # Win Condition
        hint_color=$GREEN
        hint_text="You've found the Golden Key!"
    elif [ $dist -le 2 ]; then
        # Very close
        hint_color=$RED
        hint_text="HOT! (1 or 2 steps away)"
    elif [ $dist -le 4 ]; then
        # Getting closer
        hint_color=$YELLOW
        hint_text="Warm (3 or 4 steps away)"
    else
        # Far away
        hint_color=$NC
        hint_text="Cold (more than 4 steps away)"
    fi

    echo -e "${hint_color}${hint_text}${NC}"
}

# Processes the direction input and checks for grid boundaries.
move_player() {
    local direction=$1
    local new_x=$PLAYER_X
    local new_y=$PLAYER_Y

    case "$direction" in
        n|N) new_y=$(( PLAYER_Y + 1 )) ;;
        s|S) new_y=$(( PLAYER_Y - 1 )) ;;
        e|E) new_x=$(( PLAYER_X + 1 )) ;;
        w|W) new_x=$(( PLAYER_X - 1 )) ;;
        *) return 1 ;; # Invalid move
    esac

    if [ $new_x -ge 0 ] && [ $new_x -le $MAX_X ] && \
       [ $new_y -ge 0 ] && [ $new_y -le $MAX_Y ]; then
        PLAYER_X=$new_x
        PLAYER_Y=$new_y
        MOVES=$(( MOVES + 1 ))
        return 0 
    else
        echo -e "${RED}Blocked! You hit the wall. Try another direction.${NC}"
        return 1 # Failure (Hit wall)
    fi
}


game_loop() {
    clear 

    echo -e "${GREEN}THE HUNT FOR THE GOLDEN KEY (5x5 GRID)${NC}"

    echo "You are in a dark, empty room. Find the hidden key."
    echo "Use thermal feedback to guide your movement (N, S, E, W)."
    echo ""
    
    local distance_before=0
    local distance_after=0
    
    initialize_game

    # Initial status display
    distance_after=$(get_distance)
    echo -e "Initial Location: ${YELLOW}X=$PLAYER_X Y=$PLAYER_Y${NC}"
    echo -e "Starting Thermal: $(get_thermal_hint)"
    
    while true; do
        # Check for Win Condition at the start of the loop
        if [ $PLAYER_X -eq $KEY_X ] && [ $PLAYER_Y -eq $KEY_Y ]; then
            
            echo -e "${GREEN}SUCCESS! You found the Golden Key!${NC}"
            echo "Total Moves: $MOVES"

            break
        fi

        
        echo -e "Current Location: ${YELLOW}X=$PLAYER_X Y=$PLAYER_Y${NC} | Moves: $MOVES"
        echo "Enter direction (N/S/E/W) or Q to quit: "
        read -r INPUT

        case "$INPUT" in
            q|Q)
                echo -e "${RED}Game Quit. The Key remains lost.${NC}"
                break
                ;;
            n|N|s|S|e|E|w|W)
                distance_before=$(get_distance)
                
                if move_player "$INPUT"; then
                    distance_after=$(get_distance)
                    
                    # Provide feedback on move effectiveness
                    if [ $distance_after -lt $distance_before ]; then
                        echo -e "${GREEN}Getting closer...${NC}"
                    elif [ $distance_after -gt $distance_before ]; then
                        echo -e "${RED}Moving away...${NC}"
                    else
                        echo -e "${YELLOW}Same distance.${NC}"
                    fi
                    
                    echo -e "New Thermal Hint: $(get_thermal_hint)"
                fi
                ;;
            *)
                echo -e "${RED}Invalid input. Use N, S, E, W, or Q.${NC}"
                ;;
        esac
    done
}


game_loop
