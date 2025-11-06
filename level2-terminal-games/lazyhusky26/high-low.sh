#!/bin/bash

echo "Guess if the next number will be higher (h) or lower (l)."
echo "Type 'exit' to quit."

current_num=$(( RANDOM % 100 + 1 ))

while true; do
    echo ""
    echo "Current number: $current_num"
    read -p "Will the next number be higher or lower? (h/l): " guess

    if [ "$guess" == "exit" ]; then
        echo "Thanks for playing!"
        break
    fi

    next_num=$(( RANDOM % 100 + 1 ))
    echo "Next number: $next_num"

    if { [ "$guess" == "h" ] && [ "$next_num" -gt "$current_num" ]; } || \
       { [ "$guess" == "l" ] && [ "$next_num" -lt "$current_num" ]; }; then
        echo "Correct!"
    elif [ "$next_num" -eq "$current_num" ]; then
        echo "Same number.... No points awarded."
    else
        echo "Wrong!"
    fi

    current_num=$next_num
done
