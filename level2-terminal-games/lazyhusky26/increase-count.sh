#!/bin/bash

count=0

echo "Press Enter to increase the count. Press Ctrl+C to quit."

while true; do
  read -r
  ((count++))
  echo "Count: $count"
done
