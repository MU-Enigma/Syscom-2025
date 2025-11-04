#!/bin/bash
declare -A morse=(
  [A]=".-" [B]="-..." [C]="-.-." [D]="-.." [E]="." [F]="..-."
  [G]="--." [H]="...." [I]=".." [J]=".---" [K]="-.-" [L]=".-.."
  [M]="--" [N]="-." [O]="---" [P]=".--." [Q]="--.-" [R]=".-."
  [S]="..." [T]="-" [U]="..-" [V]="...-" [W]=".--" [X]="-..-"
  [Y]="-.--" [Z]="--.." [1]=".----" [2]="..---" [3]="...--"
  [4]="....-" [5]="....." [6]="-...." [7]="--..." [8]="---.."
  [9]="----." [0]="-----"
)

echo "Enter a word to convert to Morse:"
read input
input=$(echo "$input" | tr '[:lower:]' '[:upper:]')

for ((i=0; i<${#input}; i++)); do
  char=${input:$i:1}
  code=${morse[$char]}
  [[ -n $code ]] && echo -n "$code " || echo -n " "
done
echo

echo "Now, decode this Morse:"
keys=(${!morse[@]})
rand=${keys[$RANDOM % ${#keys[@]}]}
echo "Morse: ${morse[$rand]}"
read -p "Your answer: " ans
ans=$(echo "$ans" | tr '[:lower:]' '[:upper:]')
[[ "$ans" == "$rand" ]] && echo "✅ Correct!" || echo "❌ Wrong, it was $rand."
