#!/bin/bash
colors=("red" "green" "blue" "yellow" "purple" "cyan" "orange")
color=${colors[$RANDOM % ${#colors[@]} ]}
read -p "Guess the color: " guess
if [ "$guess" == "$color" ]; then
    echo "Correct! The color was $color."
else
    echo "Wrong! The color was $color."
fi
