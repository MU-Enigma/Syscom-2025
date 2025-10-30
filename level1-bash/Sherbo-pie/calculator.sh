#!/bin/bash

echo "Enter your first operand:"
read a
echo "Enter your operator: (+,-,*,/)"
read op
echo "Enter your second operand:"
read b

if [ "$op" == "+" ]; then
     echo "Result: $((a+b))"
elif [ "$op" == "-" ]; then
     echo "Result: $((a-b))"
elif [ "$op" == "*" ]; then
     echo "Result: $((a*b))"
elif [ "$op" == "/" ]; then
     echo "Result: $((a/b))"
else
     echo "Invalid Operator!"
fi

