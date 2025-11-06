#!/bin/bash

# Function to generate random number
generate_random_number() {
    echo $(( RANDOM % 100 + 1 ))  # Random number between 1 and 100
}

# Function to display the number line
display_number_line() {
    echo -n "Number Line: "
    for i in $(seq 1 100); do
        if [ $i -eq $1 ]; then
            echo -n "[*] "  # Show the player's guess
        else
            echo -n "$i "
        fi
    done
    echo
}

# Game Introduction
echo "Welcome to the Number Line Challenge!"
echo "I will give you a number, and you must guess where it lies on the number line from 1 to 100."
echo "Try to guess the number's position on the line."

# Generate a random target number
target_number=$(generate_random_number)
guessed=false

# Main Game Loop
while [ "$guessed" == false ]; do
    # Ask the player to guess
    read -p "Guess the number (between 1 and 100): " player_guess

    # Check if the guess is valid
    if [[ ! "$player_guess" =~ ^[0-9]+$ ]] || [ "$player_guess" -lt 1 ] || [ "$player_guess" -gt 100 ]; then
        echo "Please enter a valid number between 1 and 100."
        continue
    fi

    # Display number line
    display_number_line $player_guess

    # Check if the guess is correct
    if [ "$player_guess" -eq "$target_number" ]; then
        echo "Congratulations! You guessed the right number: $target_number."
        guessed=true
    elif [ "$player_guess" -lt "$target_number" ]; then
        echo "The number is higher than your guess."
    else
        echo "The number is lower than your guess."
    fi
done

echo "Thanks for playing the Number Line Challenge!"
