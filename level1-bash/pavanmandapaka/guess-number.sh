secret=$((RANDOM % 100 + 1))

echo "Guess a number between 1 and 100:"

while true
do
    read guess
    if [ "$guess" -eq "$secret" ]; then
        echo "Correct! "
        break
    elif [ "$guess" -lt "$secret" ]; then
        echo "low!"
    else
        echo "high!"
    fi
done
