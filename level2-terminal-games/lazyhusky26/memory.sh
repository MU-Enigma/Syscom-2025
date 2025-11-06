#!/bin/bash

sequence=()
symbols=(1 2 3 4 5 6 7 8 9 0)

echo "Welcome to the Memory Game!"
echo "Try to remember the sequence of numbers."
sleep 2

round=1

while true; do
    echo
    echo "Round $round"
    sequence+=(${symbols[$RANDOM % ${#symbols[@]}]})
    echo "Memorize this sequence:"
    echo "${sequence[@]}"
    sleep $((2 + round))
    clear
    read -p "Enter the sequence separated by spaces: " -a user_input
    if [ "${user_input[*]}" != "${sequence[*]}" ]; then
        echo "Wrong! Game over."
        echo "The correct sequence was: ${sequence[@]}"
        break
    fi
    echo "Correct!"
    ((round++))
done
