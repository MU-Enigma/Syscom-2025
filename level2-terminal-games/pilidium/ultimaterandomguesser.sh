#1/bin/bash

# I've typed all of this by hand (don't accuse me of clanking, mi feel bad).
# I did look up for syntax and stuff on the internet, but that's unavoidable.
# So there's that.
# Hope you'll like this :D

function abs {
    local d
    d=$(( $1 - $2 ))
    # Parameter expansion of the format ${parameter#pattern} which removes the shortest
    # pattern from parameter from the beginning
    d=${d#-}
    echo $d
}

clear

TIMES=5
FINISH=100

echo ""
echo -----------------------------------------------------------------------------
echo ""
echo "                 Welcome to the ULTIMATE Random Guesser!"
echo ""
echo "                   If you think you are lucky, try me!"
echo ""
echo -----------------------------------------------------------------------------
echo ""
echo "  Rules:"
echo "      1. The system keeps chooses a number (integer from 1-$FINISH) once."
echo "      2. Every time, you guess a number (integer from 1-$FINISH) and provide"
echo "       another number (deviation) representing how far could the number"
echo "       be from the system's number (integer from 0-$(( $FINISH - 1 )))."
echo "      3. Score is given by:"
echo "       sum( abs( actual - guess ) + abs( abs( actual - guess ) - deviation ) )"
echo "       The lower the score, the better."
echo "      4. After turn 1, every turn shows total score."
echo "      5. Current turn's deviation cannot be greater than that of the previous"
echo "       turn."
echo ""
echo -----------------------------------------------------------------------------
echo ""

INPUT=""
echo Press y to continue...
while [[ $INPUT != "y" ]]; do
    # s for silent (won't be shown on screen), n for max number of chars that can be read
    read -s -n 1 INPUT
done

# ANSI escape codes to move up the cursor by one line and delete the line
printf "\033[1A\033[K"

# Loading effect (74 dots become hashes)
DOTS="........................................................................."
HASHES="#########################################################################"
for i in {1..30}; do
    sleep 0.1
    # \r sends the cursor to the beginning of the line
    # printf doesn't have \n at the end by default (of course)
    # And welcome to string slicing, we have ${string:offset:length}
    printf "\r[%s]%s" "${HASHES:0:i}${DOTS:i}" "                              "
done
for i in {1..20}; do
    sleep 0.2
    printf "\r[%s]%s" "${HASHES:0:30+i}${DOTS:30+i}" "                              "
done
for i in {1..10}; do
    sleep 0.3
    printf "\r[%s]%s" "${HASHES:0:50+i}${DOTS:50+i}" "                              "
done
for i in {1..14}; do
    sleep 0.1
    printf "\r[%s]%s" "${HASHES:0:60+i}${DOTS:60+i}" "                              "
done
sleep 1

clear
echo ""
echo -----------------------------------------------------------------------------
echo ""
echo "                 Welcome to the ULTIMATE Random Guesser!"
echo ""
echo "                   If you think you are lucky, try me!"
echo ""
echo -----------------------------------------------------------------------------
echo ""
echo "  Rules:"
echo "      1. The system keeps chooses a number (integer from 1-$FINISH) once."
echo "      2. Every time, you guess a number (integer from 1-$FINISH) and provide"
echo "       another number (deviation) representing how far could the number"
echo "       be from the system's number (integer from 0-$(( $FINISH - 1 )))."
echo "      3. Score is given by:"
echo "       sum( abs( actual - guess ) + abs( abs( actual - guess ) - deviation ) )"
echo "       The lower the score, the better."
echo "      4. After turn 1, every turn shows total score."
echo "      5. Current turn's deviation cannot be greater than that of the previous"
echo "       turn."
echo ""
echo -----------------------------------------------------------------------------
echo ""

CHOOSE=$(( $RANDOM % $FINISH ))
echo The system has chosen its number!
echo ""

sleep 1

# Clearing input buffer, just in case (necessary)
# t for timeout, N for exact number of chars to be read
read -t 0.01 -N 10000000

SCORE=0

TURN=1
PREVDEV=$(( $FINISH - 1 ))     # Setting max possible value
while [[ $TURN -le $TIMES ]]; do
    echo TURN $TURN:
    read -p "Guess the number: " NUM
    while [[ $NUM -lt 1 || $NUM -gt $FINISH ]]; do
        read -p "Out of range! Type again: " NUM
    done
    read -p "Estimate the deviation: " DEV
    while [[ $DEV -lt 0 || $DEV -gt $PREVDEV ]]; do
        read -p "Out of range! Type again: " DEV
    done
    DIFF=$(abs $CHOOSE $NUM)
    SCORE=$(( $SCORE +  $DIFF + $(abs $DIFF $DEV) ))
    if [ $TURN -ne 1 ]; then
        echo Your current cumulative score: $SCORE
    fi
    echo ""
    TURN=$(( TURN + 1 ))
    sleep 0.5
    if [ $CHOOSE -eq $NUM ]; then
        break
    fi
    PREVDEV=$DEV
done

echo Actual number: $CHOOSE
echo Your final score: $SCORE
echo ""

INPUT=""
echo Press x to exit...
while [[ $INPUT != "x" ]]; do
    read -s -n 1 INPUT
done
clear