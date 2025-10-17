echo ""
echo "playing rock paper scissors,with a code is crazy,what you have no friends aa?anyways welcome to rock paper scissors game!"
echo "Enter what do you choose choice,trust me i choosed before u choosed a move (rock, paper, scissors): "
read choice
options=("rock" "paper" "scissors")
code_choice=${options[$RANDOM % 3]}
echo "the code choosed: $code_choice"
if [ "$choice" == "$code_choice" ]; then
    echo "It's a tie!"
elif [ "$choice" == "rock" ] && [ "$code_choice" == "scissors" ] || 
     [ "$choice" == "paper" ] && [ "$code_choice" == "rock" ] || 
     [ "$choice" == "scissors" ] && [ "$code_choice" == "paper" ]; then
    echo "luck one you are ...You win!"
else
    echo "skill issue  the Computer wins!"
fi
echo "Thanks for playing!,play irl next time"