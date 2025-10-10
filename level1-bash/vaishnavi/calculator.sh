#!/bin/bash

# Ask for the first number
echo "Enter first number:"
read num1

# Ask for the second number
echo "Enter second number:"
read num2

# Ask for the operation
echo "Enter operation (+ - * /):"
read op

# Calculate using if-elif-else (easier for beginners)
if [ "$op" = "+" ]; then
    result=$((num1 + num2))
elif [ "$op" = "-" ]; then
    result=$((num1 - num2))
elif [ "$op" = "*" ]; then
    result=$((num1 * num2))
elif [ "$op" = "/" ]; then
    if [ $num2 -ne 0 ]; then
        result=$((num1 / num2))
    else
        echo "Error: Division by zero!"
        exit 1
    fi
else
    echo "Invalid operation!"
    exit 1
fi

# Show the result
echo "Result: $result"