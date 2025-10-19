number=$(( RANDOM % 100 + 1 ))

echo "Guess the number between 1 and 100"

while true; do
  read guess
  if (( guess < number )); then
    echo "Too low"
  elif (( guess > number )); then
    echo "Too high"
  else
    echo "Correct! The number was $number"
    break
  fi
done

