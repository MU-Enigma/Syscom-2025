NUMBER=$((RANDOM % 10 + 1))

read -p "Guess a number between 1 and 10: " GUESS

if [ $GUESS -eq $NUMBER ]; then
    echo "Right! The number was $NUMBER"
else
    echo "Wrong! The number was $NUMBER"
fi