#!/bin/bash

# A text-based version of the classic FLAMES game.

# --- Helper Functions ---

# Function to calculate the "FLAMES count" by removing common letters.
# This function is the core logic of the game.
get_flames_count() {
  # Sanitize inputs: lowercase and remove non-alphabetic characters.
  local name1=$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alpha:]')
  local name2=$(echo "$2" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alpha:]')

  local total_count=0

  # Iterate through every letter of the alphabet.
  for char in {a..z}; do
    # Count occurrences of the letter in each name.
    local count1=$(echo "$name1" | tr -cd "$char" | wc -c)
    local count2=$(echo "$name2" | tr -cd "$char" | wc -c)
    
    # The number of remaining letters for this character
    # is the absolute difference of their counts.
    # e.g., "alex" (1 'a') vs "alabama" (4 'a's). diff = 3.
    local diff=$((count1 - count2))
    local abs_diff=${diff#-} 
    
    total_count=$((total_count + abs_diff))
  done

  echo $total_count
}

# --- Main Game Script ---

echo "--- Welcome to the FLAMES Game! ---"
echo ""

read -p "Enter the first name: " name1
read -p "Enter the second name: " name2
echo ""

count=$(get_flames_count "$name1" "$name2")

# Check if the names are identical or have no unique letters.
if [[ $count -eq 0 ]]; then
  echo "The names are identical or have no unique letters. Cannot play FLAMES."
  exit 0
fi

echo "Calculating..."
sleep 1 

flames_str="FLAMES"
current_index=0

# Loop until only one letter remains in the flames_str
while [[ ${#flames_str} -gt 1 ]]; do
  len=${#flames_str}
  index_to_remove=$(( (current_index + count - 1) % len ))

  flames_str="${flames_str:0:index_to_remove}${flames_str:index_to_remove+1}"

  current_index=$(( index_to_remove % ${#flames_str} ))
done

final_letter=$flames_str

echo "The result is:"
case $final_letter in
  "F") echo "Friends" ;;
  "L") echo "Lovers" ;;
  "A") echo "Affection" ;;
  "M") echo "Marriage" ;;
  "E") echo "Enemies" ;;
  "S") echo "Siblings" ;;
esac
echo ""