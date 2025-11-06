#!/bin/bash

draw_card() {
    echo $((RANDOM % 10 + 2))
}

sum_cards() {
    local sum=0
    for card in "$@"; do
        sum=$((sum + card))
    done
    echo $sum
}

player_cards=($(draw_card) $(draw_card))
while true; do
    player_sum=$(sum_cards "${player_cards[@]}")
    echo "Your cards: ${player_cards[@]} (Total: $player_sum)"
    
    if [ "$player_sum" -gt 21 ]; then
        echo "Bust! You lose."
        exit
    fi

    read -p "Hit or stand? (h/s): " choice
    if [ "$choice" = "h" ]; then
        player_cards+=($(draw_card))
    else
        break
    fi
done

dealer_cards=($(draw_card) $(draw_card))
dealer_sum=$(sum_cards "${dealer_cards[@]}")
while [ "$dealer_sum" -lt 17 ]; do
    dealer_cards+=($(draw_card))
    dealer_sum=$(sum_cards "${dealer_cards[@]}")
done

echo "Dealer's cards: ${dealer_cards[@]} (Total: $dealer_sum)"

if [ "$dealer_sum" -gt 21 ] || [ "$player_sum" -gt "$dealer_sum" ]; then
    echo "You win!"
elif [ "$player_sum" -lt "$dealer_sum" ]; then
    echo "Dealer wins!"
else
    echo "It's a tie!"
fi
