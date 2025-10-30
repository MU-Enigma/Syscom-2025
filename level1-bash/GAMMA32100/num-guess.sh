
target=$(( RANDOM % 100 + 1 ))
attempts=0

echo "I'm thinking of a number between 1 and 100..."
echo "Try to guess it!"

while true; do
  read -p "Enter your guess: " guess
  ((attempts++))

  if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
    echo " That's not even a number, nigga. Try again!"
    continue
  fi

  if (( guess < target )); then
    echo " Too low! Try again."
  elif (( guess > target )); then
    echo " Too high! Try again."
  else
    echo " YEEHAWWW! You got it in $attempts attempts!"
    break
  fi
done
