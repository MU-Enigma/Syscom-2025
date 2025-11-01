#!/bin/bash


# Array of truth questions
truths=(
    "What is your biggest fear?"
    "Who was your first crush?"
    "What's the most embarrassing thing you've done?"
    "Have you ever lied to your best friend?"
    "What's a secret you've never told anyone?"
)

# Array of dares
dares=(
    "Do 10 push-ups"
    "Sing a song out loud"
    "Do a silly dance for 30 seconds"
    "Talk in a funny voice until your next turn"
    "Imitate someone in the room"
)

# Welcome message
echo " Welcome to Truth or Dare!"
read -p "Enter player names separated by spaces: " -a players
num_players=${#players[@]}

# Main game loop
while true; do
    echo ""
    echo "Players: ${players[@]}"
    read -p "Enter player name (or 'exit' to quit): " current
    if [[ "$current" == "exit" ]]; then
        echo "Thanks for playing! "
        break
    fi

    # Validate player
    if [[ ! " ${players[@]} " =~ " ${current} " ]]; then
        echo " Player not found!"
        continue
    fi

    # Randomly select truth or dare
    choice=$((RANDOM % 2))
    if [[ $choice -eq 0 ]]; then
        # Truth
        q=${truths[$((RANDOM % ${#truths[@]}))]}
        echo " TRUTH: $q"
    else
        # Dare
        d=${dares[$((RANDOM % ${#dares[@]}))]}
        echo " DARE: $d"
    fi

    echo ""
    read -p "Press Enter for next turn..."
done
