#!/bin/bash
echo "Lucky Number Game"
echo ""
echo "Pick your lucky number (1-10): "
read pnum
echo ""
echo "Spinning the wheel of fortune  :O"
rnum=$((RANDOM % 10 + 1))
echo ""
echo "Your number: $pnum"
echo "Lucky number: $rnum"
echo ""

if ["$pnum"-eq"$rnum" ]; then
    echo "You picked the lucky number! You WIN! YAYYYYY"
else
    echo "Not this time :( , Try again!"