#!/bin/bash
# CLIMB THE TOWER
floor=0
while ((floor<20)); do
  read -p "Roll dice (Enter) " _
  roll=$((RANDOM%6+1))
  floor=$((floor+roll))
  trap=$((RANDOM%10))
  echo "Rolled:$roll -> Floor:$floor"
  if ((trap==0)); then echo "Trap! Fall down 3 floors!"; ((floor-=3)); fi
  ((floor<0))&&floor=0
done
echo "You reached the top!"
