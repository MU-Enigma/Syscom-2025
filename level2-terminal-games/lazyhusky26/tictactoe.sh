#!/bin/bash

board=(" " " " " " " " " " " " " " " " " ")

draw_board() {
    echo " ${board[0]} | ${board[1]} | ${board[2]} "
    echo "---|---|---"
    echo " ${board[3]} | ${board[4]} | ${board[5]} "
    echo "---|---|---"
    echo " ${board[6]} | ${board[7]} | ${board[8]} "
}

check_win() {
    win_combinations=( 
        "0 1 2" "3 4 5" "6 7 8"
        "0 3 6" "1 4 7" "2 5 8"
        "0 4 8" "2 4 6"
    )
    for combo in "${win_combinations[@]}"; do
        read -r a b c <<< "$combo"
        if [[ ${board[a]} != " " && ${board[a]} == ${board[b]} && ${board[b]} == ${board[c]} ]]; then
            echo "${board[a]}"
            return
        fi
    done
    echo ""
}

player="X"
moves=0

while true; do
    draw_board
    read -p "Player $player, enter position (1-9): " pos
    ((pos--))
    
    if [[ $pos -lt 0 || $pos -gt 8 || ${board[pos]} != " " ]]; then
        echo "Invalid move! Try again."
        continue
    fi

    board[pos]=$player
    ((moves++))

    winner=$(check_win)
    if [[ $winner != "" ]]; then
        draw_board
        echo "Player $winner wins!"
        break
    elif [[ $moves -eq 9 ]]; then
        draw_board
        echo "It's a draw!"
        break
    fi

    if [[ $player == "X" ]]; then
        player="O"
    else
        player="X"
    fi
done
