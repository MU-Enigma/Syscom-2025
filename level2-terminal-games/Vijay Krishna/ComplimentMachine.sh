#!/bin/bash

echo "Welcome to the Compliment Machine!"
echo "It knows your worth. What's your name?"
read name

# An array of compliments
compliments=(
    "your code is probably less broken than most."
    "you have an excellent taste in shell scripts."
    "you are smarter than a sack of hammers."
    "at least 4 out of 5 dentists probably like you."
    "you are a beautiful and unique snowflake."
    "your high-fives are legendary."
    "you could definitely win a staring contest against a cat."
)

# Get the total number of items in the array
num_compliments=${#compliments[@]}

# Get a random index
index=$((RANDOM % num_compliments))

echo ""
echo "Ah, $name. The machine has decided:"
echo "You, $name, ${compliments[$index]}"

read -p "Press [Enter] to exit the Compliment Machine."