#!/bin/bash

echo "Welcome to Russian Roulette!"
echo "Spinning the cylinder..."
sleep 1

bullet=$(( RANDOM % 6 + 1 ))
chamber=$(( RANDOM % 6 + 1 ))

echo "Pulling the trigger..."
sleep 2

if [ "$chamber" -eq "$bullet" ]; then
    echo "Bang! You're dead."
    exit 1
else
    echo "Click! You survived."
fi
