#!/bin/bash

read -p "Enter first number: " num1
read -p "Enter second number: " num2
read -p "Enter operation (+ - * /): " op

case $op in
    +)
        result=$((num1+num2))
        ;;
    -)
        result=$((num1-num2))
        ;;
    \*)
        result=$((num1*num2))
        ;;
    /)
        if [ $num2 -ne 0 ]
        then
            result=$((num1/num2))
        else
            echo "Division by 0 is not valid"
        fi
        ;;
    *)
        echo Invalid operator
        ;;
esac
echo Result: $result
