#!/bin/bash

# Bash script to check if a number is positive, negative, or zero
read -p "Enter a number: " num

if [ $num -gt 0 ]
then
    echo "The number is positive"
elif [ $num -lt 0 ]
then
    echo "The number is negative"
else
    echo "The number is zero"
fi
