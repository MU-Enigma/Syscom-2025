#!/bin/bash
# SPELLCRAFT
hp=100; enemy=100; freeze=0
echo "⚔️ SPELLCRAFT - Defeat the rival wizard!"
while ((hp>0 && enemy>0)); do
  echo "Your HP:$hp | Enemy:$enemy"
  echo "1) Fireball  2) Ice  3) Lightning"
  read -p "Choose: " spell
  cpu=$((RANDOM%3+1))
  [[ $freeze -gt 0 ]] && { cpu=0; ((freeze--)); echo "Enemy is frozen!"; }
  case $spell in
    1)((enemy-=30)); echo "🔥 Fireball hits!";;
    2)((enemy-=20)); ((freeze=1)); echo "❄️ Ice freezes enemy!";;
    3)((enemy-=25)); ((hp-=10)); echo "⚡ Lightning backfires!";;
  esac
  case $cpu in
    1)((hp-=30)); echo "Enemy casts Fireball!";;
    2)((hp-=20)); echo "Enemy casts Ice!";;
    3)((hp-=25)); echo "Enemy uses Lightning!";;
  esac
  echo
  sleep 1
done
[[ $hp -gt 0 ]] && echo "🏆 You won!" || echo "💀 You were defeated!"
