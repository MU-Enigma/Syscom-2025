b=( . {1..9} )
p=X
m=0

print_b() {
    clear
    echo "  Tic-Tac-Toe"
    echo "---------------"
    echo " | ${b[1]} | ${b[2]} | ${b[3]} |"
    echo " |---|---|---|"
    echo " | ${b[4]} | ${b[5]} | ${b[6]} |"
    echo " |---|---|---|"
    echo " | ${b[7]} | ${b[8]} | ${b[9]} |"
    echo "---------------"
}

check_w() {
    for i in 1 4 7; do [[ ${b[$i]} == $p && ${b[$i+1]} == $p && ${b[$i+2]} == $p ]] && return 0; done
    for i in 1 2 3; do [[ ${b[$i]} == $p && ${b[$i+3]} == $p && ${b[$i+6]} == $p ]] && return 0; done
    [[ ${b[1]} == $p && ${b[5]} == $p && ${b[9]} == $p ]] && return 0
    [[ ${b[3]} == $p && ${b[5]} == $p && ${b[7]} == $p ]] && return 0
    return 1
}

while [[ $m -lt 9 ]]; do
    print_b
    echo "Player $p's turn. Enter a number (1-9):"
    read -r n

    if ! [[ "$n" =~ ^[1-9]$ && ${b[$n]} != "X" && ${b[$n]} != "O" ]]; then
        echo "Invalid move or cell taken. Try again."
        sleep 1
        continue
    fi

    b[$n]=$p
    ((m++))

    if check_w; then
        print_b
        echo "Player $p wins!"
        exit 0
    fi

    [[ $p == "X" ]] && p="O" || p="X"
done

print_b
echo "It's a draw!"
exit 0