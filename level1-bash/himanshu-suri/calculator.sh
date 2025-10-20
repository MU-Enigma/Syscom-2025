#!/bin/bash
echo "Enter the first number"
read num1
echo "Enter the second number"
read num2
echo "Enter the operator (+-%*)"
read op
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
	result=$((num1/num2))
	;;
*)
	echo "Invalid operator"
	exit i
	;;
	esac 
	echo "Result: $result"

