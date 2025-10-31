#!/bin/bash
word="bash"
hidden_word=$(echo "$word" | sed 's/./_/g')
attempts=6
while [[ $attempts -gt 0 && "$hidden_word" != "$word" ]]; do
    echo "Current word: $hidden_word"
    read -p "Guess a letter: " letter
    if [[ "$word" == *"$letter"* ]]; then
        echo "$letter is in the word!"
        hidden_word=$(echo "$word" | sed "s/[^$letter]/_/g")
    else
        ((attempts--))
        echo "Wrong! You have $attempts attempts left."
    fi
done
if [[ "$hidden_word" == "$word" ]]; then
    echo "Congratulations! You guessed the word."
else
    echo "Sorry! The word was $word."
fi
