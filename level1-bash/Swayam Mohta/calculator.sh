#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <num1> <operator> <num2>"
    echo "Operators: + - x /"
    exit 1
fi

num1=$1
operator=$2
num2=$3

# Perform calculation
case $operator in
    +)
        result=$((num1 + num2))
        ;;
    -)
        result=$((num1 - num2))
        ;;
    x|X|\*)
        result=$((num1 * num2))
        ;;
    /)
        # Handle division by zero
        if [ "$num2" -eq 0 ]; then
            echo "Error: Division by zero!"
            exit 1
        fi
        result=$((num1 / num2))
        ;;
    *)
        echo "Invalid operator! Use one of + - x /"
        exit 1
        ;;
esac

# Display result
echo "Result: $result"
