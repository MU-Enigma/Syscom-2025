#!/bin/bash
echo "Enter a number"
read num

if [ $num -lt 10 ]; then
    echo "$num is less than 10"
else
    echo "$num is greater than or equal to 10"
fi

