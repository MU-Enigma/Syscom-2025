#!/bin/bash
echo "Enter a number:"
read num

if [ $num -le 10 ]; then
    echo "That's 10 or less!"
else
    echo "That's greater than 10!"
fi
