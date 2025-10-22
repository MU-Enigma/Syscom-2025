#!/bin/bash

echo Enter a number in between 1 through 10:
read num

if [ $num -le 1 -o $num -gt 10 ] ; then
    echo I think I gave you a specific range...
fi
while [ $num -le 1 -o $num -gt 10 ] ; do
    read num
done

echo "Here are the square of numbers from 1 through the number you've given:"

for (( i=1; i<=num; i++)) ; do
    echo "$i^2 = $(( i * i ))"
done