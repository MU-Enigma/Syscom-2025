#!/bin/bash

echo "Rolling the dice..."
sleep 1

number=$((RANDOM % 6 + 1))
echo "You rolled a $number!"