#!/bin/bash
# MATH BLITZ - Quick math challenge

score=0
time_per_q=5

echo "MATH BLITZ: Answer before time runs out!"
sleep 1

for ((i=1; i<=10; i++)); do
  a=$((RANDOM % 10 + 1))
  b=$((RANDOM % 10 + 1))
  op=$((RANDOM % 2))
  if (( op == 0 )); then
    ans=$((a + b))
    echo -n "$i) $a + $b = "
  else
    ans=$((a * b))
    echo -n "$i) $a × $b = "
  fi

  read -t "$time_per_q" user_ans
  if [[ "$user_ans" == "$ans" ]]; then
    echo " Correct!"
    ((score++))
  else
    echo " Wrong! Answer: $ans"
  fi
done

echo "Final Score: $score / 10"
