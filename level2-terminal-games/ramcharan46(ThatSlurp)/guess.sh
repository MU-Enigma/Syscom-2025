
n=$((RANDOM%10+1))
echo "guess a number between (1-10): "
read g

if [ $g -eq $n ]; then
    echo "your guess was right!"
else
    echo "your guess was wrong :(, the number was $n"
fi