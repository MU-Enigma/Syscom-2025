#!/bin/bash
echo "=== Equation Solver ==="
a=$((RANDOM % 10 + 1))
b=$((RANDOM % 10 + 1))
x=$((RANDOM % 10 + 1))
y=$((a * x + b))
echo "Solve for x: $a*x + $b = $y"
read -p "x = " ans
if [ "$ans" -eq "$x" ]; then
  echo " Correct!"
else
  echo " Wrong! x = $x"
fi
