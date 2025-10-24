#!/usr/bin/env bash
echo "Simple Calculator"
read -p "Enter first number: " a
read -p "Enter an operator (+ - * /): " op
read -p "Enter second number: " b

case $op in
  +) result=$((a + b));;
  -) result=$((a - b));;
  \*) result=$((a * b));;
  /) result=$((a / b));;
  *) echo "Invalid operator"; exit 1;;
esac

echo "Result: $result"