#!/bin/bash

echo Enter first number:
read a
echo Enter second number:
read b
echo "Enter operation (+ - * /):"
read OP

if [ $b -eq 0 -a $OP == "/" ]; then
    echo Division error
else
    echo "Result: $(( $a $OP $b ))"
fi