#!/bin/bash

# A simple text-based Blackjack (21) game.

# --- Global Variables & Setup ---
suits=('H' 'D' 'C' 'S') # Hearts, Diamonds, Clubs, Spades
values=('2' '3' '4' '5' '6' '7' '8' '9' '10' 'J' 'Q' 'K' 'A')
deck=()
player_hand=()
dealer_hand=()

# Associative array to map card values to points.
declare -A card_values
card_values=( ["2"]=2 ["3"]=3 ["4"]=4 ["5"]=5 ["6"]=6 ["7"]=7 ["8"]=8 ["9"]=9 ["10"]=10 ["J"]=10 ["Q"]=10 ["K"]=10 ["A"]=11 )

# --- Game Functions ---

# Function to create a standard 52-card deck.
create_deck() {
  deck=()
  for suit in "${suits[@]}"; do
    for value in "${values[@]}"; do
      deck+=("$value-$suit")
    done
  done
}

# Function to shuffle the deck.
shuffle_deck() {
  # Using shuf if available, otherwise a manual shuffle.
  if command -v shuf >/dev/null 2>&1; then
    deck=($(shuf -e "${deck[@]}"))
  else
    local i
    for i in {51..1}; do
      local j=$((RANDOM % (i + 1)))
      local temp=${deck[$i]}
      deck[$i]=${deck[$j]}
      deck[$j]=$temp
    done
  fi
}

# Function to deal one card from the top of the deck.
deal_card() {
  # Returns the card value and removes it from the deck array.
  local card=${deck[0]}
  deck=("${deck[@]:1}")
  echo "$card"
}

# Function to calculate the total value of a hand.
# It intelligently handles Aces (11 or 1).
calculate_hand_value() {
  local hand=("${@}")
  local total=0
  local ace_count=0

  for card in "${hand[@]}"; do
    local value=${card%-*}
    total=$((total + card_values[$value]))
    if [[ "$value" == "A" ]]; then
      ace_count=$((ace_count + 1))
    fi
  done

  # If the total is over 21 and there's an Ace,
  # change the Ace's value from 11 to 1 by subtracting 10.
  while [[ $total -gt 21 && $ace_count -gt 0 ]]; do
    total=$((total - 10))
    ace_count=$((ace_count - 1))
  done

  echo $total
}

# --- Main Game Loop ---
echo "--- Welcome to Bash Blackjack! ---"

while true; do
  create_deck
  shuffle_deck

  # Initial deal: two cards each.
  player_hand=($(deal_card) $(deal_card))
  dealer_hand=($(deal_card) $(deal_card))

  # Player's turn
  while true; do
    player_score=$(calculate_hand_value "${player_hand[@]}")
    dealer_up_card=${dealer_hand[1]}

    echo ""
    echo "Dealer's Hand: [?, $dealer_up_card]"
    echo "Your Hand: [${player_hand[*]}] (Value: $player_score)"
    echo ""

    if [[ $player_score -ge 21 ]]; then
      break # End player's turn if they have 21 or bust.
    fi

    read -p "Your turn. (h)it or (s)tand? " choice
    if [[ "$choice" == "h" ]]; then
      echo "Dealing..."
      player_hand+=($(deal_card))
    elif [[ "$choice" == "s" ]]; then
      echo "You stand with $player_score."
      break
    else
      echo "Invalid choice. Please enter 'h' or 's'."
    fi
  done

  player_score=$(calculate_hand_value "${player_hand[@]}")
  dealer_score=$(calculate_hand_value "${dealer_hand[@]}")

  echo ""
  # Handle immediate player bust
  if [[ $player_score -gt 21 ]]; then
    echo "Your hand: [${player_hand[*]}] (Value: $player_score)"
    echo "*** BUST! You lose. ***"
  else
    # Dealer's turn
    echo "Dealer's turn..."
    sleep 1
    echo "Dealer reveals their hand: [${dealer_hand[*]}] (Value: $dealer_score)"

    while [[ $dealer_score -lt 17 ]]; do
      sleep 1
      echo "Dealer hits."
      dealer_hand+=($(deal_card))
      dealer_score=$(calculate_hand_value "${dealer_hand[@]}")
      echo "Dealer's new hand: [${dealer_hand[*]}] (Value: $dealer_score)"
    done

    if [[ $dealer_score -gt 21 ]]; then
      echo "Dealer busts!"
    else
      echo "Dealer stands."
    fi

    # Determine the winner
    echo ""
    echo "--- Result ---"
    echo "Your hand value: $player_score"
    echo "Dealer's hand value: $dealer_score"
    if [[ $dealer_score -gt 21 ]] || [[ $player_score -gt $dealer_score ]]; then
      echo "*** YOU WIN! ***"
    elif [[ $dealer_score -gt $player_score ]]; then
      echo "*** DEALER WINS! ***"
    else
      echo "*** PUSH (It's a tie)! ***"
    fi
  fi

  echo ""
  read -p "Play again? (y/n) " play_again
  if [[ "$play_again" != "y" ]]; then
    break
  fi
done

echo "Thanks for playing!"
