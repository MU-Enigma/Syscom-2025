#!/usr/bin/env bash

echo "Welcome to Mini Hangman!"

words=("bash" "syscom" "hacktober" "game" "loop" "enigma" "terminal")
secret=${words[$(( RANDOM % ${#words[@]} ))]}

display=$(echo "$secret" | sed 's/./_/g')
tries=6

echo "Guess the word! It has ${#secret} letters. You have $tries tries."
echo "$display"

while [ $tries -gt 0 ]; do
  read -p "Enter a letter: " letter
  letter=${letter,,}

  if [[ ! "$letter" =~ ^[a-z]$ ]]; then
    echo "Please enter one letter (a-z)."
    continue
  fi

  new_display=""
  for (( i=0; i<${#secret}; i++ )); do
    c=${secret:$i:1}
    if [[ "$c" == "$letter" || "${display:$i:1}" != "_" ]]; then
      new_display+="$c"
    else
      new_display+="_"
    fi
  done
  display=$new_display

  echo "$display"

  if [[ "$display" == "$secret" ]]; then
    echo "You guessed it! The word was '$secret'."
    exit 0
  fi

  ((tries--))
  echo "Tries left: $tries"
done

echo "Out of tries! The word was '$secret'."