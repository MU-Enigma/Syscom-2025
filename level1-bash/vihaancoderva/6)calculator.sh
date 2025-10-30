#!/bin/bash
# ----- Calculator -----
read -p "Enter first number: " num1
read -p "Enter operator (+ - * /): " op
read -p "Enter second number: " num2

case $op in
    +) result=$((num1 + num2));;
    -) result=$((num1 - num2));;
    \*) result=$((num1 * num2));;
    /) 
        if [ $num2 -ne 0 ]; then
            result=$((num1 / num2))
        else
            echo "Division by zero not allowed."
            exit 1
        fi
        ;;
    *) echo "Invalid operator"; exit 1;;
esac

echo "Result: $result"
