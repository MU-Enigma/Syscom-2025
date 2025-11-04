#!/bin/bash
words=("dragon" "castle" "forest" "wizard" "robot" "treasure" "storm" "friend" "portal" "moon" "spaceship" "island" "ghost" "hero" "mystery")

echo " Rolling your story dice..."
sleep 1
story=""
for i in {1..5}; do
  word=${words[$RANDOM % ${#words[@]}]}
  echo "Word $i: $word"
  story="$story $word"
  sleep 0.7
done

echo
echo "📝 Your story prompt:"
echo "\"$story\""
