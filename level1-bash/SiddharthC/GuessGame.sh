# guess_number.sh

target=$(( (RANDOM % 20) + 1 ))
tries=0


echo "I have a number between 1 and 20. Try to guess it!"


while true; do
read -p "Your guess: " guess
((tries++))


if [[ "$guess" -lt "$target" ]]; then
echo "Too low!"
elif [[ "$guess" -gt "$target" ]]; then
echo "Too high!"
else
echo "Correct! You guessed it in $tries tries."
break
fi
done
