#!/bin/bash

echo Enter a number:
read a
echo Enter another number:
read b

if [ $a -le $b ]; then
	STR='less than'
elif [ $a -eq $b ]; then
	STR='equal to'
else
	STR='greater than'
fi

echo $a is ${STR} $b
