#!/bin/bash

echo "Welcome to the Magic 8-Ball!"
echo "Ask a yes/no question (and press Enter):"
read question

# An array of possible answers
answers=(
    "It is certain."
    "It is decidedly so."
    "Without a doubt."
    "Yes - definitely."
    "Reply hazy, try again."
    "Ask again later."
    "Better not tell you now."
    "Cannot predict now."
    "Don't count on it."
    "My reply is no."
    "Outlook not so good."
    "Very doubtful."
)

# Get the total number of items in the array
num_answers=${#answers[@]}

# Get a random index from 0 to (num_answers - 1)
index=$((RANDOM % num_answers))

echo ""
echo "The 8-Ball says: ${answers[$index]}"

read -p "Press Enter to close..."