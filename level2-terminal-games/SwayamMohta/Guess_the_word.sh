#!/bin/bash
word="linux"
read -p "Guess the word: " guess
if [ "$guess" == "$word" ]; then
    echo "You guessed it right!"
else
    echo "Wrong guess! The word was $word."
fi
