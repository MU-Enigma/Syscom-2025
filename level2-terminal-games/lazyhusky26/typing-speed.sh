#!/bin/bash

sentences=(
    "The quick brown fox jumps over the lazy dog."
    "Bash scripting is fun and powerful."
    "Practice makes perfect."
    "Typing fast improves with repetition."
)

sentence=${sentences[$RANDOM % ${#sentences[@]}]}

echo "Type the sentence exactly as shown:"
echo ""
echo "$sentence"
echo ""

start=$(date +%s%N)

read -p "> " input

end=$(date +%s%N)

if [ "$input" != "$sentence" ]; then
    echo "The sentence was not typed correctly."
    echo "Your input: $input"
    echo "Expected: $sentence"
    exit 0
fi

elapsed=$(( (end - start) / 1000000 ))
seconds=$(echo "scale=3; $elapsed/1000" | bc)

echo "You typed it correctly."
echo "Time taken: $seconds seconds"
