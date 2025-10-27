#!/bin/bash

# Checks if a student meets the 75% attendance requirement

echo -n "Enter total number of classes: "
read total

echo -n "Enter number of classes attended: "
read attended

# Calculate percentage using bc for decimal precision
percentage=$(echo "scale=2; ($attended / $total) * 100" | bc)

echo "Attendance Percentage: $percentage%"

if (( $(echo "$percentage >= 75" | bc -l) )); then
  echo " You are eligible to write the exams."
else
  echo " You are NOT eligible to write the exams (attendance below 75%)."
fi

