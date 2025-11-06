#!/bin/bash

echo -n "Enter first number: "
read num1

echo -n "Enter second number: "
read num2

echo -n "Enter operation (+ - * /): "
read op

if ! [[ "$num1" =~ ^-?[0-9]+$ && "$num2" =~ ^-?[0-9]+$ ]]; then
    echo "Error: Please enter valid integers."
    exit 1
fi

case $op in
    +)
        result=$((num1 + num2))
        ;;
    -)
        result=$((num1 - num2))
        ;;
    \*)
        result=$((num1 * num2))
        ;;
    /)
        if [ "$num2" -eq 0 ]; then
            echo "Error: Division by zero"
            exit 1
        fi
        result=$((num1 / num2))
        ;;
    *)
        echo "Invalid operator"
        exit 1
        ;;
esac

echo "Result: $result"
