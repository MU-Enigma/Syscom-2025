#!/bin/bash
echo "============================="
echo "Simple Calculator"
echo "============================="
echo "Enter first number:"
read num1
echo "Enter operator (+, -, x, /):"
read op
echo "Enter second number:"
read num2
case $op in
  +) result=$((num1 + num2));;
  -) result=$((num1 - num2));;
  x|X|\*) result=$((num1 * num2));;
  /)
    if [ "$num2" -eq 0 ]; then
      echo "Error: Division by zero!"
      exit 1
    fi
    result=$((num1 / num2))
    ;;
  *)
    echo "Invalid operator. Use +, -, x, or /."
    exit 1
    ;;
esac
echo "Result: $num1 $op $num2 = $result"