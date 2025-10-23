#!/usr/bin/env bash
# magic8ball.sh – mystical yes/no fortune teller

echo "Welcome to the Magic 8-Ball!"
echo "Ask any yes/no question, then press Enter (or type 'quit' to exit)."
echo

responses=(
  "Yes, definitely."
  "No way."
  "Ask again later."
  "It is certain."
  "Very doubtful."
  "Without a doubt."
  "Better not tell you now."
  "Signs point to yes."
  "Concentrate and ask again."
  "Outlook not so good."
  "You may rely on it."
  "My reply is no."
  "Cannot predict now."
  "Most likely."
)

while true; do
  read -p "Your question: " question
  if [[ "$question" =~ ^[Qq](uit)?$ ]]; then
    echo "Farewell, seeker of truth 👋"
    break
  fi
  index=$(( RANDOM % ${#responses[@]} ))
  echo "🔮 ${responses[$index]}"
  echo
done