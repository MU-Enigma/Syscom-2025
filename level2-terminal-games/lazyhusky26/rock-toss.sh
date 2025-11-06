#!/bin/bash

score=0
throws=5

echo "Welcome to Rock Toss!"
echo "Try to hit the target by choosing a throw power between 1 and 100."
echo "The closer your throw to the target distance, the higher your score."
sleep 2

for ((i=1; i<=throws; i++)); do
    target=$((RANDOM % 100 + 1))
    read -p "Throw #$i: Enter your power (1-100): " power
    
    if [[ $power -lt 1 || $power -gt 100 ]]; then
        echo "Invalid power! Using 50 as default."
        power=50
    fi

    distance=$(( power - target ))
    if (( distance < 0 )); then
        distance=$(( -distance ))
    fi

    round_score=$(( 100 - distance ))
    if (( round_score < 0 )); then
        round_score=0
    fi

    score=$(( score + round_score ))

    echo "Target was at $target."
    echo "Your throw: $power."
    echo "Distance from target: $distance."
    echo "Score this throw: $round_score"
    echo "Total score: $score"
    echo "-----------------------"
done

echo "Game over! Final score: $score"
