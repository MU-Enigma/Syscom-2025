#!/bin/bash

# Snake Game in Bash
# Controls: w(up) s(down) a(left) d(right) q(quit)

# Terminal setup
stty -echo -icanon time 0 min 0

# Game variables
WIDTH=40
HEIGHT=20
SCORE=0
GAME_OVER=0

# Snake initial position and direction
snake_x=(20 19 18)
snake_y=(10 10 10)
DIR="RIGHT"

# Food position
food_x=$((RANDOM % (WIDTH-2) + 1))
food_y=$((RANDOM % (HEIGHT-2) + 1))

# Cleanup function
cleanup() {
    stty sane
    tput cnorm
    clear
    echo "Game Over! Final Score: $SCORE"
    exit 0
}

trap cleanup EXIT INT TERM

# Hide cursor
tput civis
clear

# Draw border once
draw_border() {
    for ((i=0; i<WIDTH; i++)); do
        tput cup 0 $i; echo -n "#"
        tput cup $((HEIGHT-1)) $i; echo -n "#"
    done
    for ((i=0; i<HEIGHT; i++)); do
        tput cup $i 0; echo -n "#"
        tput cup $i $((WIDTH-1)); echo -n "#"
    done
}

# Initial draw
draw_initial() {
    # Clear playing area
    for ((i=1; i<HEIGHT-1; i++)); do
        for ((j=1; j<WIDTH-1; j++)); do
            tput cup $i $j; echo -n " "
        done
    done
    
    # Draw initial snake
    for ((i=0; i<${#snake_x[@]}; i++)); do
        tput cup ${snake_y[$i]} ${snake_x[$i]}
        if [ $i -eq 0 ]; then
            echo -n "O"
        else
            echo -n "o"
        fi
    done
    
    # Draw food
    tput cup $food_y $food_x
    echo -n "*"
}

# Update display (only redraw what changed)
update_display() {
    local tail_idx=$((${#snake_x[@]}-1))
    
    # Erase old tail position (only if snake didn't grow)
    if [ ${#old_snake_x[@]} -eq ${#snake_x[@]} ]; then
        tput cup ${old_snake_y[$tail_idx]} ${old_snake_x[$tail_idx]}
        echo -n " "
    fi
    
    # Draw new head
    tput cup ${snake_y[0]} ${snake_x[0]}
    echo -n "O"
    
    # Update old head to body
    if [ ${#snake_x[@]} -gt 1 ]; then
        tput cup ${snake_y[1]} ${snake_x[1]}
        echo -n "o"
    fi
    
    # Draw food if position changed
    tput cup $food_y $food_x
    echo -n "*"
    
    # Update score
    tput cup $HEIGHT 2
    echo -n "Score: $SCORE | Controls: w(up) s(down) a(left) d(right) q(quit)    "
}

# Check collision
check_collision() {
    local head_x=${snake_x[0]}
    local head_y=${snake_y[0]}
    
    # Wall collision
    if [ $head_x -le 0 ] || [ $head_x -ge $((WIDTH-1)) ] || 
       [ $head_y -le 0 ] || [ $head_y -ge $((HEIGHT-1)) ]; then
        GAME_OVER=1
        return
    fi
    
    # Self collision
    for ((i=1; i<${#snake_x[@]}; i++)); do
        if [ $head_x -eq ${snake_x[$i]} ] && [ $head_y -eq ${snake_y[$i]} ]; then
            GAME_OVER=1
            return
        fi
    done
}

# Move snake
move_snake() {
    # Save old position
    old_snake_x=("${snake_x[@]}")
    old_snake_y=("${snake_y[@]}")
    
    local new_x=${snake_x[0]}
    local new_y=${snake_y[0]}
    
    case $DIR in
        "UP")    new_y=$((new_y-1)) ;;
        "DOWN")  new_y=$((new_y+1)) ;;
        "LEFT")  new_x=$((new_x-1)) ;;
        "RIGHT") new_x=$((new_x+1)) ;;
    esac
    
    # Check if food is eaten
    if [ $new_x -eq $food_x ] && [ $new_y -eq $food_y ]; then
        SCORE=$((SCORE+10))
        # Generate new food
        food_x=$((RANDOM % (WIDTH-4) + 2))
        food_y=$((RANDOM % (HEIGHT-4) + 2))
        # Add to snake (don't remove tail)
        snake_x=($new_x "${snake_x[@]}")
        snake_y=($new_y "${snake_y[@]}")
    else
        # Move snake
        snake_x=($new_x "${snake_x[@]}")
        snake_y=($new_y "${snake_y[@]}")
        # Remove tail
        unset snake_x[${#snake_x[@]}-1]
        unset snake_y[${#snake_y[@]}-1]
    fi
}

# Read input (non-blocking)
read_input() {
    local key
    # Read multiple times to catch input better
    for i in {1..5}; do
        read -t 0.001 -n 1 key
        case $key in
            w|W) [ "$DIR" != "DOWN" ] && DIR="UP"; return ;;
            s|S) [ "$DIR" != "UP" ] && DIR="DOWN"; return ;;
            a|A) [ "$DIR" != "RIGHT" ] && DIR="LEFT"; return ;;
            d|D) [ "$DIR" != "LEFT" ] && DIR="RIGHT"; return ;;
            q|Q) cleanup ;;
        esac
    done
}

# Main game loop
draw_border
draw_initial

while [ $GAME_OVER -eq 0 ]; do
    read_input
    move_snake
    check_collision
    update_display
    sleep 0.15
done

cleanup
