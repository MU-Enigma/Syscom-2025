#!/bin/bash

echo "Welcome to the Flip a Coin game!"

while true; do
    read -p "Guess heads or tails (or type 'q' to exit): " guess
    guess=$(echo "$guess" | tr '[:upper:]' '[:lower:]')

    if [[ "$guess" == "q" ]]; then
        echo "Thanks for playing!"
        break
    fi

    if [[ "$guess" != "heads" && "$guess" != "tails" ]]; then
        echo "Invalid input. Please guess 'heads' or 'tails'."
        continue
    fi

    flip=$(( RANDOM % 2 ))
    if [[ $flip -eq 0 ]]; then
        result="heads"
    else
        result="tails"
    fi

    echo "The coin landed on $result."

    if [[ "$guess" == "$result" ]]; then
        echo "Correct!"
    else
        echo "Wrong!!!! Try again!"
    fi
    echo
done
