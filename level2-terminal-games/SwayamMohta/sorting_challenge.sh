#!/bin/bash
echo "=== Sorting Challenge ==="
nums=($(shuf -i 1-9 -n 5))
echo "Arrange these numbers in ascending order: ${nums[@]}"
read -p "Enter sorted list (space separated): " -a user
sorted=($(printf '%s\n' "${nums[@]}" | sort -n))
if [ "${user[*]}" == "${sorted[*]}" ]; then
  echo " Correct!"
else
  echo " Wrong! Correct order: ${sorted[*]}"
fi
