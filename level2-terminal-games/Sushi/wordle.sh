#!/bin/bash

words=("apple" "brain" "chair" "dance" "earth" "flame" "grape" "house" "image" "jelly")
word=${words[$((RANDOM % ${#words[@]}))]}
attempts=6
word_length=5

echo "Guess the $word_length-letter word"
echo "Enter your guesses:"

for ((attempt=1; attempt<=attempts; attempt++)); do
    while true; do
        read -p "Attempt $attempt: " guess
        guess=$(echo "$guess" | tr '[:upper:]' '[:lower:]')
        
        if [ ${#guess} -ne $word_length ]; then
            echo "Word must be $word_length letters"
        else
            break
        fi
    done
    
    output=""
    correct=0
    
    for ((i=0; i<word_length; i++)); do
        char="${guess:$i:1}"
        if [ "$char" = "${word:$i:1}" ]; then
            output+="\033[32m$char\033[0m"
            ((correct++))
        elif [[ $word == *"$char"* ]]; then
            output+="\033[33m$char\033[0m"
        else
            output+="\033[90m$char\033[0m"
        fi
    done
    
    echo -e "$output"
    
    if [ $correct -eq $word_length ]; then
        echo "You won!"
        exit
    fi
done

echo "Game over. The word was: $word"