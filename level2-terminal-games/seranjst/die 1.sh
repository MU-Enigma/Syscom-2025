#!/bin/bash

SCORE_PLAYER=0
SCORE_COMPUTER=0

roll_die() {
    # Generates a random number between 1 and 6
    echo $(( (RANDOM % 6) + 1 ))
}

display_score() {
    echo "--- Current Score ---"
    echo "Player: $SCORE_PLAYER | Computer: $SCORE_COMPUTER"
    echo "---------------------"
}

play_round() {
    
    echo "Press ENTER to roll your die..."
    read -r -s
    
    PLAYER_ROLL=$(roll_die)
    COMPUTER_ROLL=$(roll_die)

    echo "You rolled a: **$PLAYER_ROLL**"
    sleep 1
    echo "Computer rolled a: **$COMPUTER_ROLL**"
    
    if [[ $PLAYER_ROLL -gt $COMPUTER_ROLL ]]; then
        echo "You WIN this round! ($PLAYER_ROLL beats $COMPUTER_ROLL)"
        SCORE_PLAYER=$((SCORE_PLAYER + 1))
    elif [[ $COMPUTER_ROLL -gt $PLAYER_ROLL ]]; then
        echo "Computer WINS this round! ($COMPUTER_ROLL beats $PLAYER_ROLL)"
        SCORE_COMPUTER=$((SCORE_COMPUTER + 1))
    else
        echo "It's a TIE! Both rolled $PLAYER_ROLL."
    fi
}

echo "--- Welcome to the High Roller Die Game! ---"
echo "Roll a six-sided die against the computer. Highest roll wins the round."
echo "Enter 'r' to Roll, or 'q' to Quit."
echo "------------------------------------------"

while true; do
    
    display_score
    
    read -r -p "Your choice (r/q): " USER_INPUT
    
    USER_INPUT=$(echo "$USER_INPUT" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$USER_INPUT" == "q" ]]; then
        echo "Game over. Thanks for playing!"
        break
    fi

    case "$USER_INPUT" in
        r)
            play_round
            ;;
        *)
            echo "Invalid input. Please enter 'r' to Roll or 'q' to Quit."
            continue
            ;;
    esac
    
    echo ""

done

echo "--- Final Tally ---"
display_score

if [[ $SCORE_PLAYER -gt $SCORE_COMPUTER ]]; then
    echo "You emerged as the overall winner!"
elif [[ $SCORE_COMPUTER -gt $SCORE_PLAYER ]]; then
    echo "The computer was luckier overall. Try again!"
else
    echo "The match ended in a draw!"
fi

echo "-------------------"