#!/bin/bash
# SPY DECODER
words=(encrypt mission agent stealth secret codebreak)
w=${words[$RANDOM%${#words[@]}]}
hidden=$(echo "$w" | sed 's/./_/g'); wrong=0

while [[ "$hidden" != "$w" && $wrong -lt 6 ]]; do
  echo "Word: $hidden | Misses:$wrong/6"
  read -n1 -p "Guess: " g; echo
  if [[ "$w" == *"$g"* ]]; then
    for ((i=0;i<${#w};i++)); do
      [[ ${w:$i:1} == "$g" ]] && hidden="${hidden:0:i}$g${hidden:$((i+1))}"
    done
  else
    ((wrong++))
    ((wrong%3==0)) && w=$(echo "$w" | fold -w1 | shuf | tr -d '\n') && echo "⚠️ Word scrambled!"
  fi
done
[[ "$hidden" == "$w" ]] && echo "✅ Decoded: $w" || echo "❌ Mission failed! Word: $w"
