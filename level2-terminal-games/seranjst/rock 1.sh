#!/bin/bash

SCORE_PLAYER=0
SCORE_COMPUTER=0
CHOICES=("rock" "paper" "scissors")

get_computer_choice() {
    local index=$(( RANDOM % 3 ))
    echo "${CHOICES[$index]}"
}

display_score() {
    echo "--- Current Score ---"
    echo "Player: $SCORE_PLAYER | Computer: $SCORE_COMPUTER"
    echo "---------------------"
}

determine_winner() {
    local player=$1
    local computer=$2

    if [[ "$player" == "$computer" ]]; then
        echo "It's a TIE!"
        return
    fi

    if ( [[ "$player" == "rock" ]] && [[ "$computer" == "scissors" ]] ) || \
       ( [[ "$player" == "paper" ]] && [[ "$computer" == "rock" ]] ) || \
       ( [[ "$player" == "scissors" ]] && [[ "$computer" == "paper" ]] ); then
        echo "You WIN! ($player beats $computer)"
        SCORE_PLAYER=$((SCORE_PLAYER + 1))
    else
        echo "Computer WINS! ($computer beats $player)"
        SCORE_COMPUTER=$((SCORE_COMPUTER + 1))
    fi
}

echo "--- Welcome to Rock-Paper-Scissors! ---"
echo "Enter 'r' for Rock, 'p' for Paper, 's' for Scissors, or 'q' to Quit."
echo "---------------------------------------"

while true; do
    
    display_score
    
    read -r -p "Your choice (r/p/s/q): " USER_INPUT
    
    USER_INPUT=$(echo "$USER_INPUT" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$USER_INPUT" == "q" ]]; then
        echo "Game over. Thanks for playing!"
        break
    fi

    case "$USER_INPUT" in
        r) PLAYER_CHOICE="rock" ;;
        p) PLAYER_CHOICE="paper" ;;
        s) PLAYER_CHOICE="scissors" ;;
        *)
            echo "Invalid input. Please enter 'r', 'p', 's', or 'q'."
            continue
            ;;
    esac

    COMPUTER_CHOICE=$(get_computer_choice)

    echo "You chose: **$PLAYER_CHOICE**"
    echo "Computer chose: **$COMPUTER_CHOICE**"
    
    determine_winner "$PLAYER_CHOICE" "$COMPUTER_CHOICE"
    
    echo ""

done

echo "--- Final Tally ---"
display_score

if [[ $SCORE_PLAYER -gt $SCORE_COMPUTER ]]; then
    echo "CONGRATULATIONS! You won the match overall!"
elif [[ $SCORE_COMPUTER -gt $SCORE_PLAYER ]]; then
    echo "Better luck next time. The computer won overall."
else
    echo "The overall match ended in a draw!"
fi

echo "-------------------"