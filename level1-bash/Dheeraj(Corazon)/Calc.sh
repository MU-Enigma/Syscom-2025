#!/bin/bash
echo "First number: "
read num1 
echo "Second number: "
read num2
echo "Enter an operator (+,-,*,/): "
read operator
case $operator in
    +) result=$((num1 + num2)) ;;
    -) result=$((num1 - num2)) ;;
    \*) result=$((num1 * num2)) ;;
    /) result=$((num1 / num2));;
    *) 
       echo "Error: Invalid operator."
       exit 1
       ;;
esac
echo "The result is: $result"