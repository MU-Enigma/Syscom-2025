#!/bin/bash

echo Enter a number
read num

if [ $num -gt 18 ]
then
    echo "You're an adult"
else
    echo "minor"
fi
