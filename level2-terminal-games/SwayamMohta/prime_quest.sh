#!/bin/bash
echo "=== Prime Quest ==="
num=$((RANDOM % 50 + 2))
read -p "Is $num a prime number? (y/n): " ans
is_prime=1
for ((i=2;i<=num/2;i++)); do
  if (( num % i == 0 )); then
    is_prime=0; break
  fi
done
if { [ "$is_prime" -eq 1 ] && [ "$ans" == "y" ]; } || \
   { [ "$is_prime" -eq 0 ] && [ "$ans" == "n" ]; }; then
  echo " Correct!"
else
  echo " Wrong!"
fi
