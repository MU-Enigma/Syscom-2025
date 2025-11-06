#!/bin/bash
# LUCKY 7 - Simple slot machine

balance=50
clear
echo "🎰 LUCKY 7: Match all 3 to win big!"
sleep 1

while (( balance > 0 )); do
  read -p "Press Enter to spin (Balance: $balance): " _
  clear
  n1=$((RANDOM % 7))
  n2=$((RANDOM % 7))
  n3=$((RANDOM % 7))
  echo "🎰 [$n1] [$n2] [$n3]"

  if (( n1==n2 && n2==n3 )); then
    echo "JACKPOT! +30 coins!"
    ((balance+=30))
  else
    echo "You lost 10 coins!"
    ((balance-=10))
  fi

  if (( balance <= 0 )); then
    echo "💸 You're out of money!"
    break
  fi
done
