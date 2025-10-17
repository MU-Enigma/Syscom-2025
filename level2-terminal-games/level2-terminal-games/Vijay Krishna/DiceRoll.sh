# ----- Dice Roll-----

echo "Welcome to the Dice Roll Game!"
echo "Enter your choice (1-6):"
read user_choice

# Computer randomly picks a number between 1 and 6
options=(1 2 3 4 5 6)
computer_choice=${options[$RANDOM % 6]}

echo "Dice landed on: $computer_choice"

# Determine result
if [ "$user_choice" == "$computer_choice" ]; then
    echo "You win! 🎉"
else
    echo "You lose!"
fi

echo "Thanks for playing! 🤖"

read -p "Press Enter to close..."