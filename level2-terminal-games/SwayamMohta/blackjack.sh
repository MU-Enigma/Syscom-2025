#!/bin/bash
# blackjack.sh - Simple terminal blackjack

draw_card() {
  echo $((RANDOM % 10 + 2))
}

player_total=0
dealer_total=0

echo "🃏 Welcome to Blackjack!"

# Player turn
while true; do
  card=$(draw_card)
  player_total=$((player_total + card))
  echo "You drew a $card. Total = $player_total"

  if [ $player_total -gt 21 ]; then
    echo "💥 Bust! You lose."
    exit
  fi

  read -p "Hit or stand? " choice
  [ "$choice" = "stand" ] && break
done

# Dealer turn
while [ $dealer_total -lt 17 ]; do
  card=$(draw_card)
  dealer_total=$((dealer_total + card))
done

echo "Dealer's total = $dealer_total"

if [ $dealer_total -gt 21 ] || [ $player_total -gt $dealer_total ]; then
  echo "🎉 You win!"
elif [ $player_total -eq $dealer_total ]; then
  echo "🤝 It's a tie!"
else
  echo "😢 Dealer wins."
fi
