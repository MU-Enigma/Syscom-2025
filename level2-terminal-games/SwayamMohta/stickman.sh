#!/bin/bash
# STICKMAN FIGHT
hp=100; enemy=100; echo "🥋 STICKMAN FIGHT - Beat your opponent!"
while ((hp>0 && enemy>0)); do
  clear; echo "Your HP:$hp | Enemy HP:$enemy"
  echo "[A] Attack | [S] Block | [D] Kick"
  read -rsn1 -t1 key
  [[ -z $key ]] && key="."
  enemy_move=$((RANDOM%3))
  case $key in
    a)((enemy-=RANDOM%20+10)); echo "You attacked!";;
    s)((hp+=5)); echo "You blocked!";;
    d)((enemy-=RANDOM%25)); echo "You kicked!";;
  esac
  case $enemy_move in
    0)((hp-=RANDOM%15+5)); echo "Enemy attacked!";;
    1)((enemy+=5)); echo "Enemy blocked!";;
    2)((hp-=RANDOM%20)); echo "Enemy kicked!";;
  esac
  ((hp>100))&&hp=100
  ((enemy>100))&&enemy=100
  sleep 0.7
done
[[ $hp -gt 0 ]] && echo "🏆 You won!" || echo "💀 Defeated!"
