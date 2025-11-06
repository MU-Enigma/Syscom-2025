#!/bin/bash
# CODEBREAKER - Guess the secret 4-digit code

generate_secret() {
  digits=($(shuf -i 0-9 -n 4))
  echo "${digits[@]}" | tr -d ' '
}

secret=$(generate_secret)
attempts=0

clear
echo "CODEBREAKER - Guess the 4-digit secret code"
echo "Clues: '+' = correct digit in right place, '-' = correct digit wrong place"
echo

while true; do
  read -p "Enter your 4-digit guess: " guess
  [[ ! "$guess" =~ ^[0-9]{4}$ ]] && echo "Enter exactly 4 digits!" && continue
  ((attempts++))

  # Count matches
  plus=0
  minus=0
  for ((i=0;i<4;i++)); do
    g=${guess:$i:1}
    s=${secret:$i:1}
    if [[ "$g" == "$s" ]]; then
      ((plus++))
    elif [[ "$secret" == *"$g"* ]]; then
      ((minus++))
    fi
  done

  echo "Result: $plus +  |  $minus -"
  if ((plus == 4)); then
    echo "You cracked the code in $attempts tries! Secret was $secret"
    break
  fi
done
