#!/bin/bash
# Task 6: Simple Calculator
echo "Enter first number:"
read a
echo "Enter second number:"
read b
echo "Enter operation (+ - * /):"
read op
case $op in
  +) echo "Result: $((a + b))";;
  -) echo "Result: $((a - b))";;
  \*) echo "Result: $((a * b))";;
  /) echo "Result: $((a / b))";;
  *) echo "Invalid operation!";;
esac
