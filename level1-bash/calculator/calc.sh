#!/bin/bash

echo "Enter first number:"
read num1

echo "Enter second number:"
read num2

echo "Enter operation (+ - * /):"
read op

if [ "$op" = "+" ]; then
    echo "Result: $((num1 + num2))"
elif [ "$op" = "-" ]; then
    echo "Result: $((num1 - num2))"
elif [ "$op" = "*" ]; then
    echo "Result: $((num1 * num2))"
elif [ "$op" = "/" ]; then
    echo "Result: $((num1 / num2))"
else
    echo "Invalid operation!"
fi

