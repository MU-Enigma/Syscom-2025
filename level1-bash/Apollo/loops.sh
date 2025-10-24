#!/bin/bash

echo "This program prints 5 numbers"
echo "Enter your number: "

read num

count=0
newcount=$((count + 5))
while [ $count -lt $newcount ];
do
  echo "Number is: $num"
  num=$((num + 1))
  count=$((count + 1))
done
