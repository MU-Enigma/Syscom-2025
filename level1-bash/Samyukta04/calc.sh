#!/bin/bash
# calc.sh
a=$1
op=$2
b=$3

if [ $# -ne 3 ]; then
  echo "Usage: $0 num1 operator num2"
  exit 1
fi

case $op in
  +) result=$((a + b));;
  -) result=$((a - b));;
  x|X|\*) result=$((a * b));;
  /) result=$((a / b));;
  *) echo "Invalid operator! Use +, -, x, or /."; exit 1;;
esac

echo "Result: $result"

