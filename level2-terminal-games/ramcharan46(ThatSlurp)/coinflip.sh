#!/usr/bin/env bash

echo "Coin Flip Game!!"
echo "Choose heads or tails(h/t):"
read choice

flip=$((RANDOM % 2))
if [$flip -eq 0];then
    res="h"
    echo "the coin landed on heads"
else
    res="t"
    echo "the coin landed on tails"
fi
if ["$choice"="$result" ];then
    echo "You win! YAYYY"
else
    echo "You lose! :("
fi
