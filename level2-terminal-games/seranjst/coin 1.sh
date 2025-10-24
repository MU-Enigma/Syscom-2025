#!/bin/bash

SCORE_PLAYER=0
SCORE_COMPUTER=0
TOSS_OPTIONS=("HEADS" "TAILS")

get_toss_result() {
    # Generate a random number (0 or 1) and use it as an index
    local index=$(( RANDOM % 2 ))
    echo "${TOSS_OPTIONS[$index]}"
}

display_score() {
    echo "--- Current Score ---"
    echo "Player: $SCORE_PLAYER | Computer: $SCORE_COMPUTER"
    echo "---------------------"
}

play_round() {
    local PLAYER_GUESS=$1
    local TOSS_RESULT=$(get_toss_result)

    echo "Flipping the coin..."
    sleep 1 # Pause for dramatic effect
    echo "The coin landed on: **$TOSS_RESULT**"

    if [[ "$PLAYER_GUESS" == "$TOSS_RESULT" ]]; then
        echo "You guessed correctly! You WIN this round."
        SCORE_PLAYER=$((SCORE_PLAYER + 1))
    else
        echo "Sorry, you guessed incorrectly. Computer WINS this round."
        SCORE_COMPUTER=$((SCORE_COMPUTER + 1))
    fi
}

echo "--- Welcome to the Coin Toss Game! ---"
echo "Guess HEADS or TAILS and see if you can beat the odds."
echo "Enter 'h' for Heads, 't' for Tails, or 'q' to Quit."
echo "--------------------------------------"

while true; do
    
    display_score
    
    read -r -p "Your guess (h/t/q): " USER_INPUT
    
    USER_INPUT=$(echo "$USER_INPUT" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$USER_INPUT" == "q" ]]; then
        echo "Game over. Thanks for playing!"
        break
    fi

    case "$USER_INPUT" in
        h) PLAYER_GUESS="HEADS" ;;
        t) PLAYER_GUESS="TAILS" ;;
        *)
            echo "Invalid input. Please enter 'h', 't', or 'q'."
            continue
            ;;
    esac

    play_round "$PLAYER_GUESS"
    
    echo ""

done

echo "--- Final Tally ---"
display_score

if [[ $SCORE_PLAYER -gt $SCORE_COMPUTER ]]; then
    echo "You beat the computer overall! Well done!"
elif [[ $SCORE_COMPUTER -gt $SCORE_PLAYER ]]; then
    echo "The computer's luck held out. Better luck next time."
else
    echo "The match ended in a perfect draw!"
fi

echo "-------------------"