#!/bin/bash
echo "🎶 Welcome to Music Guess!"
echo "Guess the melody from beep sequences!"

songs=("Twinkle" "Mario" "Beep Symphony")
choice=$((RANDOM % 3))

echo "Playing melody..."
for i in {1..5}; do
  printf '\a'
  sleep 0.3
done

read -p "Which song was it? (Twinkle/Mario/Beep Symphony): " guess
if [[ "${guess,,}" == "${songs[$choice],,}" ]]; then
  echo "✅ Correct! You guessed $guess."
else
  echo "❌ It was ${songs[$choice]}!"
fi
