#!/bin/bash

sci="s"
rock="r"
paper="p"

turn="s"

echo "Welcome to a game of rock paper and scissors"

echo "Choose an option rock(r), paper(p) or scissors(s)"

read option

flag=1

while [ $flag -eq 1 ];
do
    if [ "$option" == "$turn" ]
    then
        echo "It's a draw, try again"
        read option
    elif [ $option = $rock ]
    then
        echo "You win"
        flag=0
    else
        echo "You lost"
        flag=0
    fi
done