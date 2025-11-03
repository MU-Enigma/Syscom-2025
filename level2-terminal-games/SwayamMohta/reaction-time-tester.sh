#!/bin/bash
echo "Press Enter when you see GO!"
sleep $((RANDOM % 5 + 2))
echo "GO!"
start=$(date +%s%3N)
read -r
end=$(date +%s%3N)
elapsed=$((end - start))
echo "Your reaction time: $elapsed ms"
