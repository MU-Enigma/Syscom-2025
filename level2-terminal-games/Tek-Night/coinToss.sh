echo "🪙🪙Welcome to the coin tosser!🪙🪙"
echo "How many times would you like to toss your coin?"
read num

heads=0
tails=0

for (( i=1; i<=num; i++ ))
do
    toss=$(( RANDOM % 2 ))
    if [ $toss -eq 0 ]; then
        echo "Toss $i: HEADS"
        ((heads++))
    else
        echo "Toss $i: TAILS"
        ((tails++))
    fi
done

echo ""
echo "Result after $num number of tosses:"
echo "Heads: $heads"
echo "Tails: $tails"