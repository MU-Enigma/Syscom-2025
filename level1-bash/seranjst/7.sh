#!/bin/bash

SECRET=42
GUESS=-1
COUNT=0

echo "Guess 0-100"

while [ $GUESS -ne $SECRET ]; do
    
    COUNT=$((COUNT + 1))
    
    read -p "#$COUNT: " GUESS
    
    if [ $GUESS -lt $SECRET ]; then
        echo "Low."
    elif [ $GUESS -gt $SECRET ]; then
        echo "High."
    fi
    
done

echo "YES! $SECRET in $COUNT."