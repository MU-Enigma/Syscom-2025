#!/bin/bash
s=("i" "t" "r" "e" "p")
len=${#s[@]}

echo "slot machine press enter"
read -n 1 -r
echo

r1=${s[$((RANDOM % len))]}
r2=${s[$((RANDOM % len))]}
r3=${s[$((RANDOM % len))]}

echo "---[ $r1 | $r2 | $r3 ]---"

if [[ $r1 == $r2 && $r2 == $r3 ]]; then
    echo "dingding"
elif [[ $r1 == $r2 || $r2 == $r3 || $r1 == $r3 ]]; then
    echo "win"
else
    echo "lose"
fi