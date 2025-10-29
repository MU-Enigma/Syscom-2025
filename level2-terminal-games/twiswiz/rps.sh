#!/bin/bash

echo "🎮 Welcome to Rock–Paper–Scissors!"
echo "---------------------------------"
echo "Rules:"
echo "Rock beats Scissors | Scissors beats Paper | Paper beats Rock"
echo ""

choices=("rock" "paper" "scissors")

while true; do
    echo ""
    read -p "👉 Enter your choice (rock/paper/scissors or quit): " player

    player=$(echo "$player" | tr '[:upper:]' '[:lower:]')

    if [[ "$player" == "quit" ]]; then
        echo "👋 Thanks for playing!"
        break
    fi

    if [[ "$player" != "rock" && "$player" != "paper" && "$player" != "scissors" ]]; then
        echo "❌ Invalid choice! Please type rock, paper, or scissors."
        continue
    fi

    comp=${choices[$RANDOM % 3]}
    echo "🖥️  Computer chose: $comp"

    if [[ "$player" == "$comp" ]]; then
        echo "😐 It's a draw!"
    elif [[ ("$player" == "rock" && "$comp" == "scissors") ||
            ("$player" == "paper" && "$comp" == "rock") ||
            ("$player" == "scissors" && "$comp" == "paper") ]]; then
        echo "🎉 You win!"
    else
        echo "💻 Computer wins!"
    fi
done

