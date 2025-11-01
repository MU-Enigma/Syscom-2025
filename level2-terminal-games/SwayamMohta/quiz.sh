#!/bin/bash
# Trivia Quiz Game

score=0
questions=(
    "What is the capital of France?;Paris"
    "Who wrote 'Hamlet'?;Shakespeare"
    "What is 5 * 6?;30"
    "What is the color of the sky?;Blue"
)

for q in "${questions[@]}"; do
    question=${q%%;*}
    answer=${q##*;}
    echo ""
    echo "$question"
    read -p "Your answer: " user
    if [[ "${user,,}" == "${answer,,}" ]]; then
        echo "✅ Correct!"
        ((score++))
    else
        echo "❌ Wrong! Correct answer: $answer"
    fi
done

echo ""
echo "Your final score: $score / ${#questions[@]}"
