#!/bin/bash

# Bash script for a simple calculator
read -p "Enter first number: " a
read -p "Enter second number: " b

echo "Select operation: + - * /"
read op

if [ "$op" == "+" ]
then
    echo "Result: $((a + b))"
elif [ "$op" == "-" ]
then
    echo "Result: $((a - b))"
elif [ "$op" == "*" ]
then
    echo "Result: $((a * b))"
elif [ "$op" == "/" ]
then
    echo "Result: $((a / b))"
else
    echo "Invalid operation"
fi
