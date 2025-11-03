#!/bin/bash
# 🔤 Anagram Challenge

words=("banana" "orange" "grape" "mango" "cherry" "peach" "strawberry" "melon")
score=0

shuffle_word() {
  echo "$1" | fold -w1 | shuf | tr -d '\n'
}

for i in {1..5}; do
  word=${words[$((RANDOM % ${#words[@]}))]}
  scrambled=$(shuffle_word "$word")

  echo "Unscramble this word: $scrambled"
  read -p "Your guess: " guess

  if [[ "$guess" == "$word" ]]; then
    echo "✅ Correct!"
    ((score++))
  else
    echo "❌ Wrong! The word was '$word'"
  fi
  echo
done

echo "Your final score: $score / 5"
