b=("1" "2" "3" "4" "5" "6" "7" "8" "9")
p="X"
t=0
print_board() {
  echo " ${b[0]} | ${b[1]} | ${b[2]} "
  echo "---+---+---"
  echo " ${b[3]} | ${b[4]} | ${b[5]} "
  echo "---+---+---"
  echo " ${b[6]} | ${b[7]} | ${b[8]} "
}
check_win() {
  for i in "X" "O"; do
    if ( [ "${b[0]}" == $i ] && [ "${b[1]}" == $i ] && [ "${b[2]}" == $i ] ) || \
       ( [ "${b[3]}" == $i ] && [ "${b[4]}" == $i ] && [ "${b[5]}" == $i ] ) || \
       ( [ "${b[6]}" == $i ] && [ "${b[7]}" == $i ] && [ "${b[8]}" == $i ] ) || \
       ( [ "${b[0]}" == $i ] && [ "${b[3]}" == $i ] && [ "${b[6]}" == $i ] ) || \
       ( [ "${b[1]}" == $i ] && [ "${b[4]}" == $i ] && [ "${b[7]}" == $i ] ) || \
       ( [ "${b[2]}" == $i ] && [ "${b[5]}" == $i ] && [ "${b[8]}" == $i ] ) || \
       ( [ "${b[0]}" == $i ] && [ "${b[4]}" == $i ] && [ "${b[8]}" == $i ] ) || \
       ( [ "${b[2]}" == $i ] && [ "${b[4]}" == $i ] && [ "${b[6]}" == $i ] ); then
      echo; print_board; echo "*******************"; echo "** PLAYER $i WINS! **"; echo "*******************"; exit 0
    fi
  done
}
while true; do
  clear; echo "================="; echo "  TIC-TAC-TOE"; echo "================="; echo
  print_board; echo
  if [ $t -eq 9 ]; then
      echo "*******************"; echo "** IT'S A DRAW! **"; echo "*******************"; exit 0
  fi
  read -p "Player $p, choose (1-9): " m
  if ! [[ "$m" =~ ^[1-9]$ ]]; then
      echo "Invalid input. Must be 1-9."; sleep 1; continue
  fi
  idx=$((m-1))
  if [[ "${b[$idx]}" == "X" ]] || [[ "${b[$idx]}" == "O" ]]; then
      echo "Spot already taken."; sleep 1; continue
  fi
  b[$idx]=$p
  ((t++))
  check_win
  if [ "$p" == "X" ]; then p="O"; else p="X"; fi
done