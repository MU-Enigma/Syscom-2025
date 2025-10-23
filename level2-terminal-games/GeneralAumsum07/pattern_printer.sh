#!/usr/bin/env bash

echo "Welcome to the Pattern Printer!"

read -p "Enter a symbol to use: " symbol
read -p "Enter the number of rows: " rows

if ! [[ "$rows" =~ ^[0-9]+$ ]] || [ "$rows" -le 0 ]; then
  echo "Please enter a positive number for rows."
  exit 1
fi

echo
echo "Here’s your pattern:"
echo

for (( i=1; i<=rows; i++ )); do
  for (( j=1; j<=i; j++ )); do
    echo -n "$symbol "
  done
  echo
done
