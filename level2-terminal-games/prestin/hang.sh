word="prestin"
len=${#word}
guessed=""
display=$(printf "_%.0s" $(seq 1 $len))
turns=6

echo "Welcome to Hangman! Word is $len letters."

while [[ $turns -gt 0 && "$display" != "$word" ]]; do
    echo "Turns left: $turns"
    echo "Word: $display"
    read -n 1 -p "Guess a letter: " l
    echo
    
    if [[ "$guessed" == *"$l"* ]]; then
        echo "Already guessed '$l'."
    elif [[ "$word" == *"$l"* ]]; then
        echo "Good guess!"
        guessed+="$l"
        display=""
        for (( i=0; i<$len; i++ )); do
            [[ "$guessed" == *"${word:$i:1}"* ]] && display+="${word:$i:1}" || display+="_"
        done
    else
        echo "Wrong!"
        guessed+="$l"
        ((turns--))
    fi
done

echo "----------------"
if [[ "$display" == "$word" ]]; then
    echo "win"
else
    echo "lose"
fi