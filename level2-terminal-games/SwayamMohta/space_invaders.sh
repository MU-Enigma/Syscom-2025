#!/bin/bash
# ASCII Space Invaders (Mini Version)

# Terminal dimensions (for simplicity)
WIDTH=20
HEIGHT=10

# Player position (bottom row)
player=$((WIDTH/2))

# Invader positions (random row 0..2)
invaders=()
for i in $(seq 0 $((RANDOM % 5 + 3))); do
  invaders+=($((RANDOM % WIDTH)))
done

# Bullet (empty initially)
bullet=-1
bullet_row=-1

score=0

# Draw function
draw() {
    clear
    for ((y=0; y<HEIGHT; y++)); do
        for ((x=0; x<WIDTH; x++)); do
            char=" "
            # Draw invaders
            for inv in "${invaders[@]}"; do
                if [[ $y -eq 0 && $x -eq $inv ]]; then
                    char="*"
                fi
            done
            # Draw bullet
            if [[ $y -eq $bullet_row && $x -eq $bullet ]]; then
                char="|"
            fi
            # Draw player
            if [[ $y -eq $((HEIGHT-1)) && $x -eq $player ]]; then
                char="^"
            fi
            echo -n "$char"
        done
        echo
    done
    echo "Score: $score"
}

# Game loop
while true; do
    draw

    # Read input (w/a/s/d or space for shoot)
    read -rsn1 -t 0.2 key

    case $key in
        a) ((player>0)) && ((player--)) ;;
        d) ((player<WIDTH-1)) && ((player++)) ;;
        " ") 
            if [[ $bullet -eq -1 ]]; then
                bullet=$player
                bullet_row=$((HEIGHT-2))
            fi
            ;;
    esac

    # Move bullet up
    if [[ $bullet -ne -1 ]]; then
        ((bullet_row--))
        # Check collision
        new_invaders=()
        hit=0
        for inv in "${invaders[@]}"; do
            if [[ $bullet_row -eq 0 && $bullet -eq $inv ]]; then
                ((score+=10))
                hit=1
            else
                new_invaders+=($inv)
            fi
        done
        invaders=("${new_invaders[@]}")
        [[ $hit -eq 1 ]] && bullet=-1
        [[ $bullet_row -lt 0 ]] && bullet=-1
    fi

    # Random new invader at top
    if ((RANDOM % 10 == 0)); then
        invaders+=($((RANDOM % WIDTH)))
    fi

    # Game over condition (invader reaches bottom)
    game_over=0
    for inv in "${invaders[@]}"; do
        if [[ $inv -ge 0 && $inv -lt WIDTH && $bullet_row -ge HEIGHT ]]; then
            :
        fi
    done

    if [[ ${#invaders[@]} -eq 0 ]]; then
        echo "You cleared all invaders! You win!"
        break
    fi
done
