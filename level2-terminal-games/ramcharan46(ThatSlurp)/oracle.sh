#!/bin/bash
echo "Ask a yes/no question: "
read q
answers=("Yes :D" "No" "Maybe ;-;")
echo "${answers[$((RANDOM % 5))]}"