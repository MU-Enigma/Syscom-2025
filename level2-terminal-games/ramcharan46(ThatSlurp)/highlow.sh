#!/bin/bash
echo "HighLow"
echo ""
echo "Hmmm,I'm thinking of a number between 1 and 100"
echo ""
echo "Is it high or low than 50?(high/low)"
read guess

num=$((RANDOM % 100 + 1))

echo ""
echo "The number was: $num"
echo ""
if ["$num"-gt 50]&&["$guess"=="high"];then
    echo "your guess was right! you win!! YAYYYY"
elif ["$num"-le 50]&&["$guess"=="low" ];then
    echo "your guess was right! you win!! YAYYYY"
else
    echo "aww, your guess was wrong :( better luck next time!"
fi