#!/bin/bash

WORDS=("RUGBY" "BLUFF" "SKATE" "BOXER" \
       "ARENA" "JENGA" "DEUCE" "GAMES" "SPORT" "QUEEN" \
       "CHESS" "CARDS" "CHECK" "LOTTO" "BINGO" "HOOPS" \
       "POKER" "JOKER" "SPADE" "HEART" "CLUBS" "RUMMY" )
SECRET=${WORDS[$RANDOM % ${#WORDS[@]}]}

MAX_ATTEMPTS=5
ATTEMPTS=0

# Keep track of which positions are already solved
KNOWN="_____"

echo "🐮 Welcome back to WordleCow!"
echo "Guess the 5-letter secret word."
echo "Clues: Revealed in correct position only, others stay hidden."
echo "You only have $MAX_ATTEMPTS WRONG attempts (guesses with NO new correct-position letters)."
echo "---------------------------------------------"

while true; do
    read -p "> " GUESS
    GUESS=$(echo "$GUESS" | tr '[:lower:]' '[:upper:]')

    if [ ${#GUESS} -ne 5 ]; then
        echo "Please enter a 5-letter word."
        continue
    fi

    RESULT=""
    NEW_MATCH=false
    for ((i=0; i<5; i++)); do
        LETTER=${GUESS:$i:1}
        if [ "${LETTER}" == "${SECRET:$i:1}" ]; then
            RESULT+="$LETTER"
            # Check if this is a new discovery
            if [ "${KNOWN:$i:1}" = "_" ]; then
                NEW_MATCH=true
                KNOWN="${KNOWN:0:$i}$LETTER${KNOWN:$((i+1))}"
            fi
        else
            RESULT+="_"
        fi
    done

    cowsay "$RESULT"

    if [ "$GUESS" == "$SECRET" ]; then
        cowsay "MOO! You got it! Let's move to Syscom Level 2.: $SECRET"
        break
    fi

    if [ "$NEW_MATCH" = false ]; then
        ((ATTEMPTS++))
        echo "❌ Wrong attempt: $ATTEMPTS/$MAX_ATTEMPTS"
    fi

    if [ $ATTEMPTS -ge $MAX_ATTEMPTS ]; then
        cowsay "GAME OVER! The word was $SECRET. Resetting..."
        SECRET=${WORDS[$RANDOM % ${#WORDS[@]}]}
        ATTEMPTS=0
        KNOWN="_____"
    fi
done
