#!/bin/bash
echo "=== Magic Square Solver ==="
square=(8 1 6 3 5 7 4 9 2)
sum=15
echo "Sum of each row/col/diag must be $sum."
read -p "Enter missing number for center (currently '?'): " num
if [ "$num" -eq 5 ]; then
  echo " Correct! Center = 5"
else
  echo " Wrong! The center is 5."
fi
