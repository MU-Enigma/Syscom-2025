#!/bin/bash
# Task 4: If-Else
echo "Enter a number:"
read num
if [ $num -gt 10 ]; then
  echo "That's greater than 10!"
else
  echo "That's 10 or less!"
fi
