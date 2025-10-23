echo "Guess a number (1-100):"
SECRET=$(( (RANDOM % 100) + 1 ))
GUESSES=0
GUESS=0 
while [ "$GUESS" -ne "$SECRET" ]; do
    read -p "Your guess: " GUESS
    ((GUESSES++))
    if ! [[ "$GUESS" =~ ^[0-9]+$ ]]; then echo "Not a number!"; continue; fi
    [ "$GUESS" -lt "$SECRET" ] && echo "Too low."
    [ "$GUESS" -gt "$SECRET" ] && echo "Too high."
done
echo "Got it! The number was $SECRET. It took you $GUESSES guesses."