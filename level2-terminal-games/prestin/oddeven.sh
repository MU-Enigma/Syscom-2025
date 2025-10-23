echo "Odd or Even"
while true; do
    while [[ "$role" != "odd" && "$role" != "even" ]]; do
        read -p "Odd (o) or Even (e)? " r
        [[ "$r" == "o" || "$r" == "O" ]] && role="odd"
        [[ "$r" == "e" || "$r" == "E" ]] && role="even"
    done

    while [[ "$p_throw" -ne 1 && "$p_throw" -ne 2 ]]; do
        read -p "Throw 1 or 2: " p_throw
    done
    
    c_throw=$(( $RANDOM % 2 + 1 ))
    sum=$(( p_throw + c_throw ))
    
    echo "You: $p_throw | Computer: $c_throw | Sum: $sum"

    if [ $(( sum % 2 )) -eq 0 ]; then
        result="even"
    else
        result="odd"
    fi

    if [ "$role" == "$result" ]; then echo "You win!"; else echo "Computer wins!"; fi

    read -p "Play again? (y/n) " again
    [[ "$again" == "n" || "$again" == "N" ]] && break
    
    role=""
    p_throw=0
done

echo "Thanks for playing!"