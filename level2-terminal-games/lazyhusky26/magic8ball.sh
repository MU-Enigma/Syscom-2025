#!/bin/bash

answers=("Yes" "No" "Maybe" "Ask again" "Definitely" "I don't think so")
echo -n "Ask a yes/no question: "
read
echo "Magic 8-ball says: ${answers[RANDOM % ${#answers[@]}]}"
