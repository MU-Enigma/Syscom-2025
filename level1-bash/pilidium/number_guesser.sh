#!/bin/bash

TOBEGUESSED=$(( (RANDOM % 100) + 1 ))
GUESSED=false

echo "Guess what the computer's thinking!"
echo Pick a random number between 1 and 100

TRIES=0
for i in {1..7}; do
    read GUESS
    TRIES=$(( TRIES + 1 ))
    if [ $GUESS -eq $TOBEGUESSED ]; then
        echo -n You guessed it in $TRIES
        if [ $TRIES -eq 1 ]; then
            echo " try!"
        else
            echo " tries!"
        fi
        GUESSED=true
        break
    elif [ $GUESS -lt $TOBEGUESSED ]; then
        echo Too low, try again!
    else
        echo Too high, try again!
    fi
done

if [[ $GUESSED == "false" ]]; then
    echo 7 tries exhausted!
fi

echo End of game...