w="prestin"
len=${#w}
gc=""
gw=""
l=6
wg=0
d=""
for (( i=0; i<$len; i++ )); do d+="_ "; done
draw() {
    echo "  +---+"
    echo "  |   |"
    if [ $wg -ge 1 ]; then echo "  O   |"; else echo "      |"; fi
    if [ $wg -eq 2 ]; then echo "  |   |"; elif [ $wg -eq 3 ]; then echo " /|   |"; elif [ $wg -ge 4 ]; then echo " /|\  |"; else echo "      |"; fi
    if [ $wg -eq 5 ]; then echo " /    |"; elif [ $wg -ge 6 ]; then echo " / \  |"; else echo "      |"; fi
    echo "      |"
    echo "========="
}
update() {
    d=""
    for (( i=0; i<$len; i++ )); do
        local c="${w:$i:1}"
        if [[ "$gc" == *"$c"* ]]; then d+="$c "; else d+="_ "; fi
    done
}
while true; do
    clear
    echo "================="; echo "  BASH HANGMAN"; echo "================="; echo
    draw
    echo
    echo "Word:    $d"
    echo "Wrong:   $gw"
    echo "Lives:   $((l - wg)) / $l"; echo
    if [[ "$d" != *"_"* ]]; then
        echo "*******************"; echo "** YOU WIN!    **"; echo "*******************"
        echo "The word was: $w"; break
    fi
    if [ $wg -ge $l ]; then
        echo "*******************"; echo "** GAME OVER!   **"; echo "*******************"
        echo "The word was: $w"; break
    fi
    read -n 1 -p "Guess a letter: " g
    g=${g,,}
    echo
    if ! [[ "$g" =~ ^[a-z]$ ]]; then
        echo "Please enter a single letter."; sleep 1; continue
    fi
    if [[ "$gc" == *"$g"* ]] || [[ "$gw" == *"$g"* ]]; then
        echo "You already guessed '$g'."; sleep 1; continue
    fi
    if [[ "$w" == *"$g"* ]]; then
        gc+="$g"; update
    else
        gw+="$g "; ((wg++))
    fi
done