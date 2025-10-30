#!/bin/bash

#bash script for a very simple calculator
echo "Enter first number: "
read num1 
echo "Enter second number: "
read num2
echo "Enter an operator (+, -, *, /): "
read operator
case $operator in
    +) result=$((num1 + num2)) ;;
    -) result=$((num1 - num2)) ;;
    \*) result=$((num1 * num2)) ;;
    /) result=$((num1 / num2));;
    *) 
       echo "Error: Invalid operator. Please use one of +, -, *, /."
       exit 1
       ;;
esac
echo "The result of $num1 $operator $num2 is: $result"