#!/bin/bash
echo "Memorize the number sequence: 5 9 3 2 8"
sleep 3
clear
read -p "What was the second number? " guess
if [ "$guess" -eq 9 ]; then
    echo "Correct!"
else
    echo "Wrong! The correct answer was 9."
fi
