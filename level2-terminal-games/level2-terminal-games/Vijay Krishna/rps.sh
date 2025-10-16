#bash script to play rock paper scissors game

echo "Welcome to Rock - Paper - Scissors Game!"
echo "Enter your choice (rock / paper / scissors): "
read user_choice

# Convert input to lowercase to handle case-insensitivity
user_choice=$(echo "$user_choice" | tr '[:upper:]' '[:lower:]')

options=("rock" "paper" "scissors")
computer_choice=${options[$RANDOM % 3]}
echo "Computer chose: $computer_choice"

if [[ "$user_choice" != "rock" && "$user_choice" != "paper" && "$user_choice" != "scissors" ]]; then
    echo "Invalid choice! Please enter rock, paper, or scissors."

elif [ "$user_choice" == "$computer_choice" ]; then
    echo "It's a tie!"

elif [[ ( "$user_choice" == "rock" && "$computer_choice" == "scissors" ) || \
        ( "$user_choice" == "paper" && "$computer_choice" == "rock" ) || \
        ( "$user_choice" == "scissors" && "$computer_choice" == "paper" ) ]]; then
    echo "You win! 🎉"
    
else
    echo "Computer wins! 🤖"
fi

echo "Thanks for playing!"

read -p "Press Enter to close..."