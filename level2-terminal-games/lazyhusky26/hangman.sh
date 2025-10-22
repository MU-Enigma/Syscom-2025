#!/bin/bash

words=("enigma" "banana" "mahindra" "balls" "normalization" "dilip" "hangman" "pneumonia" "xylophone" "quizzical")

word=${words[$RANDOM % ${#words[@]}]}
word_length=${#word}
guessed=()
wrong_guesses=0
max_wrong=6

display_word=$(printf "_%.0s" $(seq 1 $word_length))

update_display_word() {
  local temp=""
  for (( i=0; i<word_length; i++ )); do
    letter=${word:i:1}
    if [[ " ${guessed[*]} " == *" $letter "* ]]; then
      temp+=$letter
    else
      temp+="_"
    fi
  done
  display_word=$temp
}

draw_hangman() {
  case $wrong_guesses in
    0)
      echo "  +---+"
      echo "  |   |"
      echo "      |"
      echo "      |"
      echo "      |"
      echo "      |"
      echo "========="
      ;;
    1)
      echo "  +---+"
      echo "  |   |"
      echo "  O   |"
      echo "      |"
      echo "      |"
      echo "      |"
      echo "========="
      ;;
    2)
      echo "  +---+"
      echo "  |   |"
      echo "  O   |"
      echo "  |   |"
      echo "      |"
      echo "      |"
      echo "========="
      ;;
    3)
      echo "  +---+"
      echo "  |   |"
      echo "  O   |"
      echo " /|   |"
      echo "      |"
      echo "      |"
      echo "========="
      ;;
    4)
      echo "  +---+"
      echo "  |   |"
      echo "  O   |"
      echo " /|\  |"
      echo "      |"
      echo "      |"
      echo "========="
      ;;
    5)
      echo "  +---+"
      echo "  |   |"
      echo "  O   |"
      echo " /|\  |"
      echo " /    |"
      echo "      |"
      echo "========="
      ;;
    6)
      echo "  +---+"
      echo "  |   |"
      echo "  O   |"
      echo " /|\  |"
      echo " / \  |"
      echo "      |"
      echo "========="
      ;;
  esac
}

while true; do
  clear
  draw_hangman
  echo
  echo "Word: $display_word"
  echo "Guessed letters: ${guessed[*]}"
  echo "Wrong guesses left: $((max_wrong - wrong_guesses))"
  echo -n "Guess a letter: "
  read -n1 guess
  echo

  guess=${guess,,}

  if [[ ! $guess =~ [a-z] ]]; then
    echo "Please enter a valid letter."
    sleep 1
    continue
  fi

  guessed+=($guess)

  if [[ $word == *"$guess"* ]]; then
    update_display_word
    if [[ $display_word == "$word" ]]; then
      clear
      draw_hangman
      echo
      echo "Word: $display_word"
      echo "You guessed the word :3"
      break
    fi
  else
    ((wrong_guesses++))
    if (( wrong_guesses >= max_wrong )); then
      clear
      draw_hangman
      echo
      echo "Game Over!"
      break
    fi
  fi
done
