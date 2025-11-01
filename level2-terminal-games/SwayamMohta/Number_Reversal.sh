#!/bin/bash
read -p "Enter a number: " number

# Initialize the reversed number variable
reversed=""

# Loop through each digit and build the reversed number
while [ $number -gt 0 ]; do
    # Get the last digit of the number
    digit=$((number % 10))
    # Append the digit to the reversed number
    reversed="${reversed}${digit}"
    # Remove the last digit from the original number
    number=$((number / 10))
done

echo "Reversed number: $reversed"
