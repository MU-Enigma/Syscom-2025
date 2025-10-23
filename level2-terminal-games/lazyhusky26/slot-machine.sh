#!/bin/bash

symbols=("🍒" "🍋" "🔔" "⭐" "💎" "7️⃣")

balance=100
cost_per_spin=10

get_symbol() {
  echo "${symbols[$((RANDOM % ${#symbols[@]}))]}"
}

calculate_winnings() {
  if [[ $1 == $2 && $2 == $3 ]]; then
    case $1 in
      "7️⃣") echo 100 ;;
      "💎") echo 50 ;;
      "⭐") echo 30 ;;
      "🔔") echo 20 ;;
      "🍋") echo 15 ;;
      "🍒") echo 10 ;;
      *) echo 0 ;;
    esac
  elif [[ $1 == $2 || $2 == $3 || $1 == $3 ]]; then
    echo 5
  else
    echo 0
  fi
}

while true; do
  echo "-----------------------------------"
  echo "  SLOT MACHINE  "
  echo "Balance: \$$balance"
  echo "Cost per spin: \$$cost_per_spin"
  echo "Press Enter to spin or 'q' to quit."
  read -r input
  if [[ $input == "q" ]]; then
    echo "Thanks for playing! Final balance: \$$balance"
    break
  fi

  if (( balance < cost_per_spin )); then
    echo "💸 You're out of money! Game over."
    break
  fi

  balance=$((balance - cost_per_spin))

  s1=$(get_symbol)
  s2=$(get_symbol)
  s3=$(get_symbol)

  echo "Spinning..."
  sleep 1
  echo "| $s1 | $s2 | $s3 |"

  winnings=$(calculate_winnings "$s1" "$s2" "$s3")
  if (( winnings > 0 )); then
    echo "You won \$$winnings!"
    balance=$((balance + winnings))
  else
    echo "WOMP WOMP. Try again!"
  fi
done
