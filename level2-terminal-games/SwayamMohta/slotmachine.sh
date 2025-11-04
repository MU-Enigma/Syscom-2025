#!/bin/bash
# slot-machine.sh - Simple slot machine game

symbols=("🍒" "🍋" "🔔" "💎" 7️⃣")

spin() {
  echo ${symbols[$((RANDOM % ${#symbols[@]}))]}
}

a=$(spin)
b=$(spin)
c=$(spin)

echo "🎰 $a | $b | $c"

if [ "$a" == "$b" ] && [ "$b" == "$c" ]; then
  echo "🎉 JACKPOT!"
else
  echo "😢 Try again!"
fi
