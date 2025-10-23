#!/bin/bash

echo "Simple Slots!"
echo "Press Enter to pull the lever..."
read

# Generate 3 random "reels", numbers from 0 to 7
reel1=$((RANDOM % 8))
reel2=$((RANDOM % 8))
reel3=$((RANDOM % 8))

echo "You spun:"
echo "  [ $reel1 ] - [ $reel2 ] - [ $reel3 ]"
echo ""

# Check if all three are the same
if [ "$reel1" -eq "$reel2" ] && [ "$reel2" -eq "$reel3" ]; then
    echo "JACKPOT! All three match! YOU WIN! YAYYYYY"
# Check if just the first two match
elif [ "$reel1" -eq "$reel2" ]; then
    echo "So close! Two matches. You win a small prize."
# Check if just the last two match
elif [ "$reel2" -eq "$reel3" ]; then
    echo "So close! Two matches. You win a small prize."
# Check if just the outer two match
elif [ "$reel1" -eq "$reel3" ]; then
    echo "So close! Two matches. You win a small prize."
else
    echo "No match. Better luck next time :("
fi

read -p "Press Enter to close..."